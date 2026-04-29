BEGIN;

-- ============================================================
-- Economics (ECN)
-- ============================================================

-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('ECN', 'Economics')
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('ECN',111,'ECN 111','Introduction to Economics',4),
('ECN',205,'ECN 205','Current State of the U.S. Economy',4),
('ECN',215,'ECN 215','Labor Economics',4),
('ECN',218,'ECN 218','Gender and the Economy',4),
('ECN',220,'ECN 220','Foundations of Policy Analysis',4),
('ECN',226,'ECN 226','Economics of Innovation',4),
('ECN',228,'ECN 228','Introduction to Managerial Economics',4),
('ECN',229,'ECN 229','American Economic History',4),
('ECN',230,'ECN 230','Economic Development',4),
('ECN',233,'ECN 233','International Economics',4),
('ECN',235,'ECN 235','Money and Banking',4),
('ECN',236,'ECN 236','Health Economics',4),
('ECN',238,'ECN 238','Economic History',4),
('ECN',240,'ECN 240','Resource and Environmental Economics',4),
('ECN',245,'ECN 245','Financial Economics',4),
('ECN',250,'ECN 250','Public Finance',4),
('ECN',262,'ECN 262',NULL,4),

('ECN',280,'ECN 280','Microeconomic Analysis',4),
('ECN',282,'ECN 282','Macroeconomic Analysis',4),
('ECN',286,'ECN 286','Econometrics',4),

('ECN',326,'ECN 326','Financial and Managerial Accounting',4),
('ECN',327,'ECN 327','Corporate Finance',4),
('ECN',328,'ECN 328','Time Series Econometrics',4),
('ECN',336,'ECN 336','Behavioral and Experimental Economics',4),
('ECN',338,'ECN 338','Applied Game Theory',4),
('ECN',339,'ECN 339','Introduction to Mathematical Economics',4),

('ECN',366,'ECN 366','Seminar in Health Economics',4),
('ECN',369,'ECN 369','Seminar in Environmental Economics',4),
('ECN',370,'ECN 370','Seminar in Political Economy',4),
('ECN',372,'ECN 372','Seminar in Economic Development',4),
('ECN',374,'ECN 374','Seminar in International Trade',4),
('ECN',375,'ECN 375','Seminar in International Finance',4),
('ECN',376,'ECN 376','Seminar in Income Distribution',4),
('ECN',378,'ECN 378','Seminar in Law and Economics',4),
('ECN',379,'ECN 379','Seminar in the Economics of Crime',4),
('ECN',380,'ECN 380','Seminar in Monetary Economics',4),
('ECN',382,'ECN 382','Seminar in Economic History',4),

('MAT',124,'MAT 124','Functions and Integral Calculus',4),
('MAT',131,'MAT 131','Calculus I',4),
('MAT',209,'MAT 209',NULL,4),
('MAT',335,'MAT 335',NULL,4),
('MAT',336,'MAT 336','Probability and Statistics II',4)

ON CONFLICT (course_code) DO UPDATE
SET title = COALESCE(EXCLUDED.title, courses.title),
    credits = EXCLUDED.credits,
    active = TRUE;

-- ------------------------------------------------------------
-- Course offering terms and prerequisites used by the planner
-- Keep course-level rules here, not in server/index.js.
-- ------------------------------------------------------------
DELETE FROM course_terms
USING courses c
WHERE course_terms.course_id = c.id
  AND c.course_code IN (
    'ECN 111','ECN 220','ECN 226','ECN 280','ECN 282','ECN 286',
    'ECN 326','ECN 327','ECN 338'
  );

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('ECN 111','Fall'), ('ECN 111','Spring'),
  ('ECN 220','Spring'),
  ('ECN 226','Fall'), ('ECN 226','Spring'),
  ('ECN 280','Fall'), ('ECN 280','Spring'),
  ('ECN 282','Fall'), ('ECN 282','Spring'),
  ('ECN 286','Fall'), ('ECN 286','Spring'),
  ('ECN 326','Fall'),
  ('ECN 327','Spring'),
  ('ECN 338','Fall'), ('ECN 338','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN (
    'ECN 215','ECN 220','ECN 226','ECN 230','ECN 245','ECN 250',
    'ECN 280','ECN 282','ECN 286','ECN 326','ECN 327','ECN 338',
    'ECN 369','ECN 370','ECN 372','ECN 374','ECN 375','ECN 376',
    'ECN 378','ECN 380'
  );

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN (
    'ECN 215','ECN 220','ECN 226','ECN 230','ECN 245','ECN 250',
    'ECN 280','ECN 282','ECN 286','ECN 326','ECN 327','ECN 338',
    'ECN 369','ECN 370','ECN 372','ECN 374','ECN 375','ECN 376',
    'ECN 378','ECN 380'
  );

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('ECN 215','ecn111','ECN 111',false),
  ('ECN 220','ecn111','ECN 111',false),
  ('ECN 226','ecn111','ECN 111',false),
  ('ECN 230','ecn111','ECN 111',false),
  ('ECN 245','ecn111','ECN 111',false),
  ('ECN 250','ecn111','ECN 111',false),
  ('ECN 280','math','MAT 124',false),
  ('ECN 280','math','MAT 131',false),
  ('ECN 280','ecn111','ECN 111',false),
  ('ECN 282','math','MAT 124',false),
  ('ECN 282','math','MAT 131',false),
  ('ECN 282','ecn111','ECN 111',false),
  ('ECN 286','stats','MAT 209',false),
  ('ECN 286','stats','MAT 335',false),
  ('ECN 326','ecn280','ECN 280',false),
  ('ECN 327','ecn280','ECN 280',false),
  ('ECN 327','ecn326','ECN 326',false),
  ('ECN 338','ecn111','ECN 111',false),
  ('ECN 338','ecn280','ECN 280',false),
  ('ECN 338','math','MAT 124',false),
  ('ECN 338','math','MAT 131',false),
  ('ECN 369','ecn280','ECN 280',false),
  ('ECN 369','empirical','ECN 262',true),
  ('ECN 369','empirical','ECN 286',false),
  ('ECN 369','empirical','MAT 336',false),
  ('ECN 370','ecn280','ECN 280',false),
  ('ECN 370','ecn282','ECN 282',false),
  ('ECN 372','ecn282','ECN 282',false),
  ('ECN 374','ecn280','ECN 280',false),
  ('ECN 375','ecn282','ECN 282',false),
  ('ECN 376','ecn280','ECN 280',false),
  ('ECN 376','ecn282','ECN 282',false),
  ('ECN 378','ecn280','ECN 280',false),
  ('ECN 380','ecn282','ECN 282',false)
) AS v(course_code, group_code, prerequisite_code, can_be_corequisite)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

INSERT INTO course_registration_rules(
  course_id,
  min_semester_index,
  min_prior_courses_dept,
  min_prior_courses_min_number,
  min_prior_courses_max_number,
  min_prior_courses_count,
  notes
)
SELECT c.id,
       v.min_semester_index,
       v.min_prior_courses_dept,
       v.min_prior_courses_min_number,
       v.min_prior_courses_max_number,
       v.min_prior_courses_count,
       v.notes
FROM courses c
JOIN (VALUES
  ('ECN 220',2,NULL,NULL,NULL,NULL,'Second-year standing.'),
  ('ECN 280',2,'ECN',205,250,1,'Second-year standing and one additional Economics course numbered 205-250.'),
  ('ECN 282',2,'ECN',205,250,1,'Second-year standing and one additional Economics course numbered 205-250.'),
  ('ECN 326',4,NULL,NULL,NULL,NULL,'Open only to third-year students and seniors.')
) AS v(
  course_code,
  min_semester_index,
  min_prior_courses_dept,
  min_prior_courses_min_number,
  min_prior_courses_max_number,
  min_prior_courses_count,
  notes
) ON v.course_code = c.course_code
ON CONFLICT (course_id) DO UPDATE
SET min_semester_index = EXCLUDED.min_semester_index,
    min_prior_courses_dept = EXCLUDED.min_prior_courses_dept,
    min_prior_courses_min_number = EXCLUDED.min_prior_courses_min_number,
    min_prior_courses_max_number = EXCLUDED.min_prior_courses_max_number,
    min_prior_courses_count = EXCLUDED.min_prior_courses_count,
    notes = EXCLUDED.notes;

-- ------------------------------------------------------------
-- 3) Core Requirements
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'ECN_CORE_111', 'ECN 111', 'must_take', 10
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'ECN_CORE_280', 'ECN 280', 'must_take', 20
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'ECN_CORE_282', 'ECN 282', 'must_take', 30
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 4) Economics Field Course
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'ECN_FIELD',
       'Economics Field Course',
       'choose_one',
       1,
       'Choose one field course from ECN 205-250.',
       40
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 5) Empirical Analysis
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'ECN_EMPIRICAL',
       'Empirical Analysis',
       'choose_one',
       1,
       'Choose ECN 286 or MAT 336. MAT 336 satisfies this requirement but does not count toward the eight-course minimum required for the major.',
       50
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 6) Advanced Analysis
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'ECN_ADV_ANALYSIS',
       'Advanced Analysis Course',
       'choose_one',
       1,
       'Choose one Economics course numbered 300-350 from the approved list.',
       60
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 7) Economics Seminars
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'ECN_SEMINARS',
       'Economics Seminars',
       'choose_n',
       2,
       'Take two seminars from the approved seminar list.',
       70
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 8) History Requirement
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'ECN_HISTORY',
       'History Requirement',
       'choose_one',
       4,
       'Complete one history course above the 100-level from a list approved by the economics department. This course does not count toward the eight-course minimum required for the major. Approved off-campus study courses should be handled by backend or approval metadata.',
       80
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

UPDATE requirement_blocks rb
SET rule_type = 'choose_one',
    min_count = 1,
    min_credits = 4
FROM majors m
WHERE rb.major_id = m.id
  AND m.code = 'ECN'
  AND rb.code = 'ECN_HISTORY';

-- ------------------------------------------------------------
-- 9) Overall major totals / policy block
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'ECN_TOTALS',
       'Major totals and course-minimum rules',
       'custom',
       32,
       'Need at least 32 credits total. A minimum of eight four-credit Economics courses is required. MAT 336 and the approved history course do not count toward the eight-course minimum.',
       90
FROM majors m
WHERE m.code = 'ECN'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 10) Attach course options
-- ------------------------------------------------------------

-- Core: ECN 111
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'ECN 111'
WHERE m.code = 'ECN'
  AND b.code = 'ECN_CORE_111'
ON CONFLICT DO NOTHING;

-- Core: ECN 280
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'ECN 280'
WHERE m.code = 'ECN'
  AND b.code = 'ECN_CORE_280'
ON CONFLICT DO NOTHING;

-- Core: ECN 282
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'ECN 282'
WHERE m.code = 'ECN'
  AND b.code = 'ECN_CORE_282'
ON CONFLICT DO NOTHING;

-- Field course options
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'ECN 205','ECN 215','ECN 218','ECN 220','ECN 226',
  'ECN 228','ECN 229','ECN 230','ECN 233','ECN 235',
  'ECN 236','ECN 238','ECN 240','ECN 245','ECN 250'
)
WHERE m.code = 'ECN'
  AND b.code = 'ECN_FIELD'
ON CONFLICT DO NOTHING;

-- Empirical analysis options
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('ECN 286','MAT 336')
WHERE m.code = 'ECN'
  AND b.code = 'ECN_EMPIRICAL'
ON CONFLICT DO NOTHING;

-- Advanced analysis options
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'ECN 326','ECN 327','ECN 328','ECN 336','ECN 338','ECN 339'
)
WHERE m.code = 'ECN'
  AND b.code = 'ECN_ADV_ANALYSIS'
ON CONFLICT DO NOTHING;

-- Seminar options
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'ECN 366','ECN 369','ECN 370','ECN 372','ECN 374',
  'ECN 375','ECN 376','ECN 378','ECN 379','ECN 380','ECN 382'
)
WHERE m.code = 'ECN'
  AND b.code = 'ECN_SEMINARS'
ON CONFLICT DO NOTHING;

-- History requirement options: any seeded HIS course above the 100-level.
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.dept = 'HIS' AND c.number > 100
WHERE m.code = 'ECN'
  AND b.code = 'ECN_HISTORY'
ON CONFLICT DO NOTHING;

COMMIT;
