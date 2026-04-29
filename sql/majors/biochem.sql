BEGIN;

-- ============================================================
-- Biological Chemistry (BCM)
-- ============================================================

-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('BCM', 'Biological Chemistry')
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('BIO',150,'BIO 150','Introduction to Biological Inquiry',4),
('BIO',251,'BIO 251','Molecules, Cells, and Organisms',4),

('CHM',129,'CHM 129','General Chemistry',4),
('CHM',210,'CHM 210','Analytical Chemistry',4),
('CHM',221,'CHM 221','Organic Chemistry I',4),
('CHM',222,'CHM 222','Organic Chemistry II',4),
('CHM',330,'CHM 330','Bioorganic Chemistry',4),
('CHM',332,'CHM 332','Biophysical Chemistry',4),
('CHM',358,'CHM 358','Instrumental Analysis',4),
('CHM',363,'CHM 363','Physical Chemistry I',4),

('BCM',262,'BCM 262','Introduction to Biological Chemistry',4),
('BCM',366,'BCM 366','Immunology',4),
('BCM',395,'BCM 395','Special Topics (Approved)',4),

('BIO',334,'BIO 334','Plant Physiology',4),
('BIO',345,'BIO 345','Advanced Genetics',4),
('BIO',365,'BIO 365','Microbiology',4),
('BIO',366,'BIO 366','Immunology (cross-listed)',4),
('BIO',370,'BIO 370','Advanced Cell Biology',4),
('BIO',375,'BIO 375','Principles of Pharmacology',4),
('BIO',380,'BIO 380','Molecular Biology',4),

('MAT',131,'MAT 131','Calculus I',4),
('MAT',133,'MAT 133','Calculus II',4),

('STA',209,'STA 209','Applied Statistics',4),
('STA',230,'STA 230','Introduction to Data Science',4),

('PHY',131,'PHY 131','General Physics I',4),
('PHY',132,'PHY 132','General Physics II',4)

ON CONFLICT (course_code) DO NOTHING;

-- ------------------------------------------------------------
-- Course offering terms and prerequisites used by the planner
-- Keep course-level rules here, not in server/index.js.
-- ------------------------------------------------------------
INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('BCM 262','Fall'), ('BCM 262','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code = 'BCM 262';

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code = 'BCM 262';

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('BCM 262','bio251','BIO 251',false),
  ('BCM 262','chm221','CHM 221',false),
  ('BCM 262','chm222','CHM 222',true)
) AS v(course_code, group_code, prerequisite_code, can_be_corequisite)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3) Core Requirements
-- ------------------------------------------------------------

-- BIO 150
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_BIO150', 'BIO 150', 'must_take', 10
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- CHM 129 OR CHM 210
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_CHEM_OR', 'CHM 129 or CHM 210', 'choose_one', 20
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- BIO 251
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_BIO251', 'BIO 251', 'must_take', 30
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- Organic sequence
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_CHM221', 'CHM 221', 'must_take', 40
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_CHM222', 'CHM 222', 'must_take', 50
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- BCM 262
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_262', 'BCM 262', 'must_take', 60
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- CHM 363
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_CORE_CHM363', 'CHM 363', 'must_take', 70
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 4) Electives (choose 1 course = 4 credits)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, min_count, sort_order)
SELECT m.id, 'BCM_ELECTIVES', 'Advanced Electives (choose 1)', 'choose_one', 1, 80
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 5) Math requirement
-- ------------------------------------------------------------

-- MAT 131
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_MATH_131', 'MAT 131', 'must_take', 90
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- MAT 133 OR STA 209 OR STA 230
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_MATH_OR', 'MAT 133 or STA 209 or STA 230', 'choose_one', 100
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 6) Physics
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_PHY131', 'PHY 131', 'must_take', 110
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BCM_PHY132', 'PHY 132', 'must_take', 120
FROM majors m WHERE m.code='BCM'
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 7) Attach course options
-- ------------------------------------------------------------

-- Must take blocks
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b, courses c, majors m
WHERE m.code='BCM'
  AND b.major_id=m.id
  AND (
    (b.code='BCM_CORE_BIO150' AND c.course_code='BIO 150') OR
    (b.code='BCM_CORE_BIO251' AND c.course_code='BIO 251') OR
    (b.code='BCM_CORE_CHM221' AND c.course_code='CHM 221') OR
    (b.code='BCM_CORE_CHM222' AND c.course_code='CHM 222') OR
    (b.code='BCM_CORE_262' AND c.course_code='BCM 262') OR
    (b.code='BCM_CORE_CHM363' AND c.course_code='CHM 363') OR
    (b.code='BCM_MATH_131' AND c.course_code='MAT 131') OR
    (b.code='BCM_PHY131' AND c.course_code='PHY 131') OR
    (b.code='BCM_PHY132' AND c.course_code='PHY 132')
  )
ON CONFLICT DO NOTHING;

-- CHM 129 OR 210
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b, courses c, majors m
WHERE m.code='BCM'
  AND b.major_id=m.id
  AND b.code='BCM_CORE_CHEM_OR'
  AND c.course_code IN ('CHM 129','CHM 210')
ON CONFLICT DO NOTHING;

-- Math OR
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b, courses c, majors m
WHERE m.code='BCM'
  AND b.major_id=m.id
  AND b.code='BCM_MATH_OR'
  AND c.course_code IN ('MAT 133','STA 209','STA 230')
ON CONFLICT DO NOTHING;

-- Electives list
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b, courses c, majors m
WHERE m.code='BCM'
  AND b.major_id=m.id
  AND b.code='BCM_ELECTIVES'
  AND c.course_code IN (
    'BIO 334','BIO 345','BIO 365','BIO 366','BIO 370','BIO 375','BIO 380',
    'BCM 366','BCM 395',
    'CHM 330','CHM 332','CHM 358'
  )
ON CONFLICT DO NOTHING;

COMMIT;
