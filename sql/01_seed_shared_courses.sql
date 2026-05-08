BEGIN;

-- ============================================================
-- Shared / cross-department courses used by current majors
-- These are courses that are reused across multiple majors
-- and should not live only inside one major file.
-- ============================================================

INSERT INTO courses(dept, number, course_code, title, credits) VALUES

-- ------------------------------------------------------------
-- Math / Statistics
-- ------------------------------------------------------------
('MAT',124,'MAT 124','Functions and Integral Calculus',4),
('MAT',131,'MAT 131','Calculus I',4),
('MAT',133,'MAT 133','Calculus II',4),
('MAT',208,'MAT 208','Discrete Structures',4),
('MAT',218,'MAT 218','Discrete Bridges to Advanced Mathematics',4),
('MAT',335,'MAT 335',NULL,4),
('MAT',336,'MAT 336',NULL,4),

('STA',209,'STA 209','Applied Statistics',4),
('STA',230,'STA 230','Introduction to Data Science',4),
('STA',335,'STA 335',NULL,4),
('STA',336,'STA 336',NULL,4),

('SST',115,'SST 115','Introduction to Statistics',4),

-- ------------------------------------------------------------
-- Physics
-- ------------------------------------------------------------
('PHY',131,'PHY 131','General Physics I',4),
('PHY',132,'PHY 132','General Physics II',4),

-- ------------------------------------------------------------
-- Common Chemistry / Biology support courses
-- ------------------------------------------------------------
('CHM',129,'CHM 129','General Chemistry',4),
('CHM',221,'CHM 221','Organic Chemistry I',4),
('CHM',222,'CHM 222','Organic Chemistry II',4),
('BCM',262,'BCM 262','Introduction to Biological Chemistry',4),

-- ------------------------------------------------------------
-- Art / Studio support courses
-- ------------------------------------------------------------
('ART',111,'ART 111','Introduction to the Studio',4),
('ART',134,'ART 134','Drawing',4),

('CLS',248,'CLS 248',NULL,4),

-- ------------------------------------------------------------
-- East Asia / regional context / cross-listed support courses
-- ------------------------------------------------------------
('EAS',213,'EAS 213',NULL,4),
('EAS',288,'EAS 288',NULL,4),
('GLS',277,'GLS 277',NULL,4),
('HIS',277,'HIS 277','China''s Rise',4),
('REL',224,'REL 224','Zen Buddhism',4),
('REL',256,'REL 256','Religion and Politics in Modern China',4),

('ARH',211,'ARH 211','Arts and Visual Cultures of China',4),
('ARH',212,'ARH 212','The Global Mongol Century: In the Footsteps of Marco Polo',4),
('ARH',213,'ARH 213','Gender and Sexuality in East Asian Art',4),
('ARH',215,'ARH 215','Collecting the "Orient"',4),

-- ------------------------------------------------------------
-- Related-field approved courses already referenced by majors
-- ------------------------------------------------------------
('ANT',221,'ANT 221',NULL,4),
('NRS',250,'NRS 250',NULL,4),
('PSY',336,'PSY 336',NULL,4),

-- ------------------------------------------------------------
-- First-year Tutorial (universal Grinnell requirement)
-- ------------------------------------------------------------
('TUT',100,'TUT 100','Tutorial',4)

ON CONFLICT (course_code) DO UPDATE
SET title = EXCLUDED.title,
    active = TRUE;

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('TUT 100', 'Fall'),
  ('TUT 100', 'Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

COMMIT;