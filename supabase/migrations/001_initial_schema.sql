-- Taptime v2.0: Supabase 초기 스키마
-- Supabase SQL Editor에서 실행하거나 supabase CLI로 적용한다.

-- ── 프리셋 테이블 ────────────────────────────────────────────

CREATE TABLE presets (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 20),
  duration_min INTEGER NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  daily_goal_min INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ── 세션 테이블 ──────────────────────────────────────────────

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  preset_id TEXT NOT NULL,
  started_at TIMESTAMPTZ NOT NULL,
  ended_at TIMESTAMPTZ NOT NULL,
  duration_seconds INTEGER NOT NULL,
  status TEXT NOT NULL,
  memo TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

-- ── 인덱스 ───────────────────────────────────────────────────

CREATE INDEX idx_presets_user_updated ON presets(user_id, updated_at);
CREATE INDEX idx_sessions_user_updated ON sessions(user_id, updated_at);

-- ── RLS (Row Level Security) ─────────────────────────────────

ALTER TABLE presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- 프리셋: 본인 데이터만 접근 가능
CREATE POLICY "Users can view own presets" ON presets
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own presets" ON presets
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own presets" ON presets
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own presets" ON presets
  FOR DELETE USING (auth.uid() = user_id);

-- 세션: 본인 데이터만 접근 가능
CREATE POLICY "Users can view own sessions" ON sessions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own sessions" ON sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sessions" ON sessions
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own sessions" ON sessions
  FOR DELETE USING (auth.uid() = user_id);

-- ── Realtime ─────────────────────────────────────────────────

ALTER PUBLICATION supabase_realtime ADD TABLE presets;
ALTER PUBLICATION supabase_realtime ADD TABLE sessions;
