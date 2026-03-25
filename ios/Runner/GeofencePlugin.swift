import Flutter
import CoreLocation
import UserNotifications

/// CLLocationManager 기반 지오펜스 모니터링 플러그인.
///
/// Dart 측 GeofenceServiceImpl과 MethodChannel로 통신한다.
/// 등록된 CLCircularRegion에 진입/퇴장 시 Dart에 이벤트를 전달하고,
/// UNUserNotificationCenter를 통해 로컬 알림을 표시한다.
///
/// 제약사항:
/// - CLLocationManager는 최대 20개 영역을 동시 모니터링 가능
/// - 백그라운드 모니터링에는 "항상 허용(Always)" 권한 필요
/// - Info.plist에 UIBackgroundModes(location)과 위치 권한 설명 필요
class GeofencePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private let channel: FlutterMethodChannel
    private let locationManager = CLLocationManager()

    /// 장소 이름 저장 (알림 메시지에 사용).
    ///
    /// 인메모리 전용 — 앱 종료 시 유실된다.
    /// GeofenceManager가 앱 시작 시 DB에서 영역을 재등록하므로 다시 채워진다.
    private var placeNames: [String: String] = [:]

    /// 프리셋 이름 저장 (알림 메시지에 사용).
    private var presetNames: [String: String] = [:]

    // MARK: - FlutterPlugin Registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.taptime.taptime/geofence",
            binaryMessenger: registrar.messenger()
        )
        let instance = GeofencePlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        locationManager.delegate = self
        // Region monitoring은 allowsBackgroundLocationUpdates 없이 백그라운드에서 동작한다.
        // 이 플래그는 startUpdatingLocation() 등 연속 위치 추적에만 필요하다.
    }

    // MARK: - MethodChannel Handler

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMonitoring":
            handleStartMonitoring(result: result)
        case "stopMonitoring":
            stopAllMonitoring()
            result(nil)
        case "addRegion":
            handleAddRegion(call: call, result: result)
        case "removeRegion":
            handleRemoveRegion(call: call, result: result)
        case "removeAllRegions":
            stopAllMonitoring()
            result(nil)
        case "checkPermission":
            result(mapAuthorizationStatus(currentAuthorizationStatus()))
        case "requestPermission":
            handleRequestPermission(result: result)
        case "getMonitoredRegionIds":
            let ids = locationManager.monitoredRegions.map { $0.identifier }
            result(Array(ids))
        case "requestNotificationPermission":
            handleRequestNotificationPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Monitoring Control

    private func handleStartMonitoring(result: @escaping FlutterResult) {
        // CLLocationManager가 등록된 영역의 모니터링을 자동 유지한다.
        // Phase D에서 앱 시작 시 DB → 네이티브 영역 재등록에 사용한다.
        result(nil)
    }

    /// 모든 영역의 모니터링을 중단하고 placeNames를 초기화한다.
    private func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        placeNames.removeAll()
        presetNames.removeAll()
    }

    // MARK: - Region Management

    private func handleAddRegion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let placeName = args["placeName"] as? String,
              let presetName = args["presetName"] as? String,
              let latitude = args["latitude"] as? Double,
              let longitude = args["longitude"] as? Double,
              let radiusMeters = args["radiusMeters"] as? Int,
              let notifyOnEntry = args["notifyOnEntry"] as? Bool,
              let notifyOnExit = args["notifyOnExit"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
            return
        }

        // CLLocationManager 최대 20개 영역 제한
        if locationManager.monitoredRegions.count >= 20 {
            // 같은 ID의 영역을 교체하는 경우는 허용
            let existingIds = locationManager.monitoredRegions.map { $0.identifier }
            if !existingIds.contains(id) {
                result(FlutterError(
                    code: "REGION_LIMIT",
                    message: "Maximum 20 regions can be monitored simultaneously",
                    details: nil
                ))
                return
            }
        }

        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(
            center: center,
            radius: CLLocationDistance(radiusMeters),
            identifier: id
        )
        region.notifyOnEntry = notifyOnEntry
        region.notifyOnExit = notifyOnExit

        placeNames[id] = placeName
        presetNames[id] = presetName
        locationManager.startMonitoring(for: region)
        print("[GeofencePlugin] Region registered: \(id) (\(placeName)) at \(latitude),\(longitude) r=\(radiusMeters)m")
        result(nil)
    }

    private func handleRemoveRegion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing region id", details: nil))
            return
        }

        if let region = locationManager.monitoredRegions.first(where: { $0.identifier == id }) {
            locationManager.stopMonitoring(for: region)
        }
        placeNames.removeValue(forKey: id)
        presetNames.removeValue(forKey: id)
        result(nil)
    }

    // MARK: - Permission

    /// 권한 요청 대기를 위한 콜백 저장
    private var pendingPermissionResult: FlutterResult?

    private func handleRequestPermission(result: @escaping FlutterResult) {
        let status = currentAuthorizationStatus()

        switch status {
        case .notDetermined:
            // 첫 요청: WhenInUse부터 시작 (iOS 정책상 Always 직접 요청 불가)
            pendingPermissionResult = result
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // WhenInUse → Always 업그레이드 시도
            pendingPermissionResult = result
            locationManager.requestAlwaysAuthorization()
        default:
            result(mapAuthorizationStatus(status))
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("[GeofencePlugin] didEnterRegion: \(region.identifier)")
        channel.invokeMethod("onRegionEntered", arguments: ["regionId": region.identifier])
        showLocalNotification(regionId: region.identifier, eventType: .entered)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("[GeofencePlugin] didExitRegion: \(region.identifier)")
        channel.invokeMethod("onRegionExited", arguments: ["regionId": region.identifier])
        showLocalNotification(regionId: region.identifier, eventType: .exited)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let statusString = mapAuthorizationStatus(currentAuthorizationStatus())
        channel.invokeMethod("onPermissionChanged", arguments: ["status": statusString])

        // 대기 중인 권한 요청 콜백 처리
        if let pendingResult = pendingPermissionResult {
            pendingResult(statusString)
            pendingPermissionResult = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[GeofencePlugin] monitoringDidFail: \(region?.identifier ?? "nil") error: \(error.localizedDescription)")
        channel.invokeMethod("onError", arguments: [
            "regionId": region?.identifier ?? "",
            "message": error.localizedDescription,
        ])
    }

    // MARK: - Local Notification

    private enum RegionEventType {
        case entered
        case exited
    }

    /// 지오펜스 진입/퇴장 시 로컬 알림을 표시한다.
    ///
    /// 네이티브에서 직접 알림을 띄워 앱이 백그라운드/종료 상태여도 동작하도록 한다.
    /// Flutter 측으로 이벤트도 전달하지만, 알림은 Flutter 엔진 초기화 전에도 표시된다.
    private func showLocalNotification(regionId: String, eventType: RegionEventType) {
        let placeName = placeNames[regionId] ?? "등록된 장소"
        let presetName = presetNames[regionId] ?? "타이머"

        let content = UNMutableNotificationContent()
        content.title = "Taptime"

        switch eventType {
        case .entered:
            content.body = "\(presetName) 타이머가 시작되었습니다 (\(placeName))"
        case .exited:
            content.body = "\(presetName) 타이머가 종료되었습니다 (\(placeName))"
        }

        content.sound = .default
        content.userInfo = [
            "regionId": regionId,
            "eventType": eventType == .entered ? "entered" : "exited",
        ]

        let request = UNNotificationRequest(
            identifier: "geofence_\(regionId)_\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: nil  // 즉시 표시
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[GeofencePlugin] Notification error: \(error.localizedDescription)")
            }
        }
    }

    /// 알림 권한을 요청한다. Dart에서 MethodChannel로 호출된다.
    private func handleRequestNotificationPermission(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[GeofencePlugin] Notification permission error: \(error.localizedDescription)")
                    result(false)
                } else {
                    print("[GeofencePlugin] Notification permission granted: \(granted)")
                    result(granted)
                }
            }
        }
    }

    // MARK: - Helpers

    /// iOS 13에서는 인스턴스 프로퍼티 authorizationStatus가 없으므로
    /// 클래스 메서드 CLLocationManager.authorizationStatus()를 사용한다.
    private func currentAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .authorizedAlways:
            return "authorizedAlways"
        @unknown default:
            return "notDetermined"
        }
    }
}
