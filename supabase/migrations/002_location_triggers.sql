-- v2.1: Location triggers for geofence-based auto tracking

CREATE TABLE location_triggers (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  place_name TEXT NOT NULL CHECK (char_length(place_name) BETWEEN 1 AND 40),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  radius_meters INTEGER NOT NULL DEFAULT 200,
  notify_on_entry BOOLEAN NOT NULL DEFAULT true,
  notify_on_exit BOOLEAN NOT NULL DEFAULT false,
  auto_start BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- FK from presets to location_triggers
ALTER TABLE presets ADD COLUMN location_trigger_id TEXT REFERENCES location_triggers(id) ON DELETE SET NULL;

-- Indexes
CREATE INDEX idx_location_triggers_user_updated ON location_triggers(user_id, updated_at);

-- RLS
ALTER TABLE location_triggers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own location_triggers" ON location_triggers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own location_triggers" ON location_triggers FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own location_triggers" ON location_triggers FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own location_triggers" ON location_triggers FOR DELETE USING (auth.uid() = user_id);

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE location_triggers;
