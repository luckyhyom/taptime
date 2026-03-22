# Supabase Setup Guide

> Step-by-step guide for setting up Supabase project, OAuth providers, and platform configuration.
> Follow each section in order.

## Prerequisites

- [Supabase](https://supabase.com) account
- [Google Cloud Console](https://console.cloud.google.com) access (for Google Sign-In)
- Apple Developer Program membership (for Apple Sign-In, optional)
- Supabase CLI installed: `brew install supabase/tap/supabase`

## 1. Supabase Project

### 1.1 CLI Login

```bash
supabase login
```

Opens browser for authentication.

### 1.2 Create Project

```bash
supabase orgs list                    # Find your org ID
supabase projects create taptime \
  --org-id <ORG_ID> \
  --region ap-northeast-1 \
  --db-password "$(openssl rand -base64 24)"
```

### 1.3 Link and Migrate

```bash
supabase link --project-ref <PROJECT_REF>
supabase db push --linked
```

This applies `supabase/migrations/001_initial_schema.sql` which creates:
- `presets` and `sessions` tables with RLS
- Indexes for efficient sync queries
- Row-Level Security policies (users access own data only)
- Realtime publication for both tables

### 1.4 Get Credentials

```bash
supabase projects api-keys --project-ref <PROJECT_REF>
```

Copy the **Project URL** and **anon key** to `.env`:

```env
SUPABASE_URL=https://<PROJECT_REF>.supabase.co
SUPABASE_ANON_KEY=<anon key value>
```

## 2. Google OAuth (Google Sign-In)

### 2.1 Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click **Select a project** > **New Project**
3. Name: `taptime`, Create

### 2.2 OAuth Consent Screen

1. Navigation menu > **APIs & Services** > **OAuth consent screen**
2. Select **External** > Create
3. Fill in:
   - App name: `Taptime`
   - User support email: your email
   - Developer contact: your email
4. Scopes: Add `email` and `profile` > Save
5. Test users: Add your Google account email > Save

### 2.3 Create OAuth Client IDs

Navigate to **APIs & Services** > **Credentials** > **Create Credentials** > **OAuth client ID**

#### Web Application (for Supabase)

- Application type: **Web application**
- Name: `Taptime Web`
- Authorized redirect URIs: `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
- Create and copy **Client ID** + **Client secret**

#### iOS App

- Application type: **iOS**
- Name: `Taptime iOS`
- Bundle ID: `com.taptime.taptime`
- Create and copy **Client ID**

#### Android App (when needed)

- Application type: **Android**
- Name: `Taptime Android`
- Package name: `com.taptime.taptime`
- SHA-1 certificate fingerprint: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`
- Create and copy **Client ID**

### 2.4 Update `.env`

```env
GOOGLE_IOS_CLIENT_ID=<iOS Client ID>.apps.googleusercontent.com
GOOGLE_WEB_CLIENT_ID=<Web Client ID>.apps.googleusercontent.com
```

### 2.5 Configure Supabase Auth

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) > your project
2. **Authentication** > **Providers** > **Google**
3. Enable Google provider
4. Client ID: paste the **Web** client ID
5. Client Secret: paste the **Web** client secret
6. Save

## 3. Apple Sign-In (Optional)

> Requires Apple Developer Program membership ($99/year).

### 3.1 Apple Developer Setup

1. Go to [Apple Developer](https://developer.apple.com/account)
2. **Certificates, Identifiers & Profiles** > **Identifiers**
3. Find or create App ID with bundle ID `com.taptime.taptime`
4. Enable **Sign in with Apple** capability

### 3.2 Create Service ID (for Supabase callback)

1. **Identifiers** > **+** > **Services IDs**
2. Identifier: `com.taptime.taptime.auth`
3. Enable **Sign in with Apple** > Configure
4. Primary App ID: select Taptime
5. Domains: `<PROJECT_REF>.supabase.co`
6. Return URLs: `https://<PROJECT_REF>.supabase.co/auth/v1/callback`

### 3.3 Create Key

1. **Keys** > **+** > Name: `Taptime Auth`
2. Enable **Sign in with Apple** > Configure > select Taptime App ID
3. Download the `.p8` key file (save securely, can only download once)
4. Note the **Key ID**

### 3.4 Configure Supabase Auth

1. Supabase Dashboard > **Authentication** > **Providers** > **Apple**
2. Enable Apple provider
3. Fill in: Secret Key (`.p8` contents), Key ID, Team ID, Service ID
4. Save

### 3.5 Xcode Configuration

The entitlements file is already created at `ios/Runner/Runner.entitlements`.
To link it in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target > **Signing & Capabilities**
3. Click **+ Capability** > **Sign in with Apple**
4. Xcode will reference the existing entitlements file

## 4. Running the App

Always pass the env file when running:

```bash
# Development
flutter run --dart-define-from-file=.env

# Build
flutter build ios --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

## 5. Verification Checklist

- [ ] Supabase project created and migration applied
- [ ] `.env` file has all 4 values (SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_IOS_CLIENT_ID, GOOGLE_WEB_CLIENT_ID)
- [ ] Google Cloud: OAuth consent screen configured
- [ ] Google Cloud: Web + iOS client IDs created
- [ ] Supabase Dashboard: Google provider enabled with Web client ID/secret
- [ ] App launches with `flutter run --dart-define-from-file=.env`
- [ ] Google Sign-In works and creates Supabase session
- [ ] (Optional) Apple Sign-In configured and working

## Security Notes

- `.env` is gitignored — never commit credentials
- Supabase anon key is client-safe (protected by RLS), but still gitignored as best practice
- `service_role` key must NEVER be used in client code
- OAuth client secrets are stored in Supabase Dashboard only, not in app code
- See `.claude/rules/pitfalls.md` for credential handling rules
