BEGIN;
 
-- ============================================================
-- Mathematics (MAT)
-- ============================================================
 
-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('MAT', 'Mathematics')
ON CONFLICT (code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('MAT',115,'MAT 115','Introduction to Statistics',4),
('MAT',123,'MAT 123','Functions and Differential Calculus',4),
('MAT',124,'MAT 124','Functions and Integral Calculus',4),
('MAT',131,'MAT 131','Calculus I',4),
('MAT',133,'MAT 133','Calculus II',4),
('MAT',208,'MAT 208','Discrete Structures',4),
('MAT',209,'MAT 209','Applied Statistics',4),
('MAT',215,'MAT 215','Linear Algebra',4),
('MAT',218,'MAT 218','Discrete Bridges to Advanced Mathematics',4),
('MAT',220,'MAT 220','Differential Equations',4),
('MAT',222,'MAT 222','Bridges to Advanced Mathematics',4),
('MAT',271,'MAT 271','Problem-Solving Seminar',1),
('MAT',306,'MAT 306','Mathematical Modeling',4),
('MAT',309,'MAT 309','Design and Analysis of Experiments',4),
('MAT',310,'MAT 310','Statistical Modeling',4),
('MAT',313,'MAT 313','Numerical Analysis',4),
('MAT',314,'MAT 314','Topics in Applied Mathematics',4),
('MAT',316,'MAT 316','Foundations of Analysis',4),
('MAT',317,'MAT 317','Advanced Topics in Analysis',4),
('MAT',321,'MAT 321','Foundations of Abstract Algebra',4),
('MAT',322,'MAT 322','Advanced Topics in Algebra',4),
('MAT',324,'MAT 324','Algebraic Number Theory',4),
('MAT',326,'MAT 326','Field Theory',4),
('MAT',331,'MAT 331','Topology',4),
('MAT',335,'MAT 335','Probability and Statistics I',4),
('MAT',336,'MAT 336','Probability and Statistics II',4),
('MAT',338,'MAT 338','Complex Analysis',4),
('MAT',444,'MAT 444','Senior Seminar',4),
 
('SST',115,'SST 115','Introduction to Statistics',4),
('STA',309,'STA 309','Applied Statistics I',4),
('STA',310,'STA 310','Applied Statistics II',4),
('STA',335,'STA 335','Probability and Statistics I (cross-listed)',4),
('STA',336,'STA 336','Probability and Statistics II (cross-listed)',4)
 
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
    'MAT 115','MAT 123','MAT 124','MAT 131','MAT 133','MAT 208',
    'MAT 209','MAT 215','MAT 218','MAT 220','MAT 222','MAT 271',
    'MAT 306','MAT 309','MAT 310','MAT 314','MAT 316','MAT 321',
    'MAT 324','MAT 326','MAT 331','MAT 335','MAT 336','MAT 338',
    'MAT 444','SST 115'
  );

INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('MAT 115','Fall'), ('MAT 115','Spring'),
  ('SST 115','Fall'), ('SST 115','Spring'),
  ('MAT 123','Fall'),
  ('MAT 124','Spring'),
  ('MAT 131','Fall'),
  ('MAT 133','Fall'), ('MAT 133','Spring'),
  ('MAT 208','Spring'),
  ('MAT 209','Fall'), ('MAT 209','Spring'),
  ('MAT 215','Fall'), ('MAT 215','Spring'),
  ('MAT 218','Fall'), ('MAT 218','Spring'),
  ('MAT 220','Spring'),
  ('MAT 222','Fall'), ('MAT 222','Spring'),
  ('MAT 271','Fall'),
  ('MAT 306','Spring'),
  ('MAT 309','Spring'),
  ('MAT 310','Fall'),
  ('MAT 314','Spring'),
  ('MAT 316','Fall'), ('MAT 316','Spring'),
  ('MAT 321','Fall'), ('MAT 321','Spring'),
  ('MAT 324','Spring'),
  ('MAT 326','Spring'),
  ('MAT 331','Fall'),
  ('MAT 335','Fall'),
  ('MAT 336','Spring'),
  ('MAT 338','Fall'),
  ('MAT 444','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN (
    'MAT 115','MAT 124','MAT 133','MAT 209','MAT 215','MAT 218',
    'MAT 220','MAT 222','MAT 271','MAT 306','MAT 309','MAT 310',
    'MAT 316','MAT 321','MAT 324','MAT 326','MAT 331','MAT 335',
    'MAT 336','MAT 338'
  );

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN (
    'MAT 115','MAT 124','MAT 133','MAT 209','MAT 215','MAT 218',
    'MAT 220','MAT 222','MAT 271','MAT 306','MAT 309','MAT 310',
    'MAT 316','MAT 321','MAT 324','MAT 326','MAT 331','MAT 335',
    'MAT 336','MAT 338'
  );

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('MAT 124','mat123','MAT 123',false),
  ('MAT 133','calc1','MAT 124',false),
  ('MAT 133','calc1','MAT 131',false),
  ('MAT 209','calc1','MAT 124',false),
  ('MAT 209','calc1','MAT 131',false),
  ('MAT 215','mat133','MAT 133',false),
  ('MAT 218','mat215','MAT 215',false),
  ('MAT 220','mat215','MAT 215',false),
  ('MAT 222','mat215','MAT 215',false),
  ('MAT 271','mat133','MAT 133',true),
  ('MAT 306','mat220','MAT 220',false),
  ('MAT 309','stats','MAT 209',false),
  ('MAT 309','stats','MAT 336',false),
  ('MAT 310','stats','MAT 209',false),
  ('MAT 310','stats','MAT 336',false),
  ('MAT 316','bridges','MAT 218',false),
  ('MAT 316','bridges','MAT 222',false),
  ('MAT 321','bridges','MAT 218',false),
  ('MAT 321','bridges','MAT 222',false),
  ('MAT 324','mat321','MAT 321',false),
  ('MAT 326','mat321','MAT 321',false),
  ('MAT 331','mat316','MAT 316',false),
  ('MAT 335','mat215','MAT 215',false),
  ('MAT 335','math_background','MAT 209',false),
  ('MAT 335','math_background','MAT 218',false),
  ('MAT 335','math_background','MAT 220',false),
  ('MAT 336','mat335','MAT 335',false),
  ('MAT 338','mat316','MAT 316',false)
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
  ('MAT 115',1,NULL,NULL,NULL,NULL,'Second semester of first-year standing and two years of high school algebra.')
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
-- 3) Core: MAT 215
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'MAT_CORE_215', 'MAT 215 Linear Algebra', 'must_take', 10
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 4) Core: Bridges (MAT 218 or MAT 222)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'MAT_CORE_BRIDGES',
       'Core: MAT 218 or MAT 222 (Bridges)',
       'choose_one',
       1,
       'Complete MAT 218 (Discrete Bridges to Advanced Mathematics) or MAT 222 (Bridges to Advanced Mathematics). MAT 215 is a prerequisite for both.',
       20
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 5) Core: MAT 316
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'MAT_CORE_316', 'MAT 316 Foundations of Analysis', 'must_take', 30
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 6) Core: MAT 321
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'MAT_CORE_321', 'MAT 321 Foundations of Abstract Algebra', 'must_take', 40
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 7) Core summary
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'MAT_CORE_SUMMARY',
       'Core summary: 16 credits',
       'custom',
       16,
       'Core consists of MAT 215, one Bridges course (MAT 218 or MAT 222), MAT 316, and MAT 321 — totaling 16 credits. MAT 218/222 is a prerequisite for MAT 316 and MAT 321.',
       50
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 8) Sequence Requirement (OR group): choose one 8-credit sequence
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, notes, sort_order
)
SELECT m.id,
       'MAT_SEQUENCE_OR',
       'Sequence Requirement: choose one 8-credit sequence',
       'or_group',
       'Complete one of the following two-course sequences: (A) MAT 313 + MAT 314, (B) MAT 316 + MAT 317, (C) MAT 321 + MAT 322, or (D) MAT 335/STA 335 + MAT 336/STA 336.',
       60
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Sequence A: Applied Mathematics
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'MAT_SEQ_A',
       'Sequence A: MAT 313 + MAT 314 (Applied Mathematics)',
       'choose_n',
       2,
       'Complete both MAT 313 (Numerical Analysis) and MAT 314 (Advanced Topics in Applied Mathematics).',
       61
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Sequence B: Analysis
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'MAT_SEQ_B',
       'Sequence B: MAT 316 + MAT 317 (Analysis)',
       'choose_n',
       2,
       'Complete both MAT 316 (Foundations of Analysis) and MAT 317 (Advanced Topics in Analysis). Note MAT 316 is already required in the core; the sequence credits the pair together.',
       62
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Sequence C: Algebra
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'MAT_SEQ_C',
       'Sequence C: MAT 321 + MAT 322 (Algebra)',
       'choose_n',
       2,
       'Complete both MAT 321 (Foundations of Abstract Algebra) and MAT 322 (Advanced Topics in Algebra). Note MAT 321 is already required in the core.',
       63
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Sequence D: Probability and Statistics
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'MAT_SEQ_D',
       'Sequence D: MAT 335/STA 335 + MAT 336/STA 336 (Probability & Statistics)',
       'choose_n',
       2,
       'Complete MAT 335 or STA 335 (Probability and Statistics I) and MAT 336 or STA 336 (Probability and Statistics II).',
       64
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 9) OR links: sequence parent -> children
-- ------------------------------------------------------------
INSERT INTO block_or_children(parent_block_id, child_block_id)
SELECT p.id, c.id
FROM requirement_blocks p
JOIN requirement_blocks c ON c.major_id = p.major_id
JOIN majors m ON m.id = p.major_id
WHERE m.code = 'MAT'
  AND p.code = 'MAT_SEQUENCE_OR'
  AND c.code IN ('MAT_SEQ_A','MAT_SEQ_B','MAT_SEQ_C','MAT_SEQ_D')
ON CONFLICT DO NOTHING;
 
-- ------------------------------------------------------------
-- 10) Policy / totals block
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'MAT_TOTALS_AND_POLICIES',
       'Major totals and policy constraints',
       'custom',
       32,
       'Minimum 32 credits total. At least 16 of the 32 credits must be at the 300- or 400-level, including MAT 316, MAT 321, and the chosen sequence. Courses numbered 297, 299, 397, 399, 499 (MAPs), plus-2s, and courses below MAT 131 do not satisfy major requirements.',
       70
FROM majors m
WHERE m.code = 'MAT'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 11) Attach course options
-- ------------------------------------------------------------
 
-- Core: MAT 215
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'MAT 215'
WHERE m.code = 'MAT'
  AND b.code = 'MAT_CORE_215'
ON CONFLICT DO NOTHING;
 
-- Core: Bridges
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 218','MAT 222')
WHERE m.code = 'MAT'
  AND b.code = 'MAT_CORE_BRIDGES'
ON CONFLICT DO NOTHING;
 
-- Core: MAT 316
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'MAT 316'
WHERE m.code = 'MAT'
  AND b.code = 'MAT_CORE_316'
ON CONFLICT DO NOTHING;
 
-- Core: MAT 321
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'MAT 321'
WHERE m.code = 'MAT'
  AND b.code = 'MAT_CORE_321'
ON CONFLICT DO NOTHING;
 
-- Sequence A
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 313','MAT 314')
WHERE m.code = 'MAT'
  AND b.code = 'MAT_SEQ_A'
ON CONFLICT DO NOTHING;
 
-- Sequence B
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 316','MAT 317')
WHERE m.code = 'MAT'
  AND b.code = 'MAT_SEQ_B'
ON CONFLICT DO NOTHING;
 
-- Sequence C
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 321','MAT 322')
WHERE m.code = 'MAT'
  AND b.code = 'MAT_SEQ_C'
ON CONFLICT DO NOTHING;
 
-- Sequence D
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 335','STA 335','MAT 336','STA 336')
WHERE m.code = 'MAT'
  AND b.code = 'MAT_SEQ_D'
ON CONFLICT DO NOTHING;
 
COMMIT;
