-- Taptime: 프리셋 보관(archive) 기능
-- presets 테이블에 archived_at 컬럼 추가

ALTER TABLE presets ADD COLUMN archived_at TIMESTAMPTZ;
