BEGIN;

-- ============================================================
-- Biology (BIO)
-- ============================================================

-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('BIO', 'Biology')
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
('BIO',150,'BIO 150','Introduction to Biological Inquiry',4),
('BIO',251,'BIO 251','Molecules, Cells, and Organisms',4),
('BIO',252,'BIO 252','Organisms, Evolution, and Ecology',4),

('BIO',297,'BIO 297','Special Studies',4),
('BIO',299,'BIO 299','Mentored Advanced Project',4),
('BIO',397,'BIO 397','Advanced Special Studies',4),
('BIO',399,'BIO 399','Advanced Mentored Advanced Project',4),
('BIO',499,'BIO 499','Senior Thesis',4),

('BCM',262,'BCM 262','Introduction to Biological Chemistry',4),

('CHM',129,'CHM 129','General Chemistry',4),
('CHM',221,'CHM 221','Organic Chemistry I',4),

('MAT',124,'MAT 124','Functions and Integral Calculus',4),
('MAT',131,'MAT 131','Calculus I',4),

('SCI',300,'SCI 300','Internships and Practica',4),

('ANT',221,'ANT 221',NULL,4),
('NRS',250,'NRS 250',NULL,4),
('PSY',336,'PSY 336',NULL,4)

ON CONFLICT (course_code) DO NOTHING;

-- ------------------------------------------------------------
-- Course offering terms and prerequisites used by the planner
-- Keep course-level rules here, not in server/index.js.
-- ------------------------------------------------------------
INSERT INTO course_terms(course_id, term)
SELECT c.id, v.term
FROM courses c
JOIN (VALUES
  ('BIO 150','Fall'), ('BIO 150','Spring'),
  ('BIO 251','Fall'),
  ('BIO 252','Spring')
) AS v(course_code, term) ON v.course_code = c.course_code
ON CONFLICT DO NOTHING;

DELETE FROM course_prerequisite_groups
USING courses c
WHERE course_prerequisite_groups.course_id = c.id
  AND c.course_code IN ('BIO 251','BIO 252');

DELETE FROM course_prerequisites
USING courses c
WHERE course_prerequisites.course_id = c.id
  AND c.course_code IN ('BIO 251','BIO 252');

INSERT INTO course_prerequisite_groups(
  course_id,
  group_code,
  prerequisite_course_id,
  can_be_corequisite
)
SELECT course.id, v.group_code, prereq.id, v.can_be_corequisite
FROM (VALUES
  ('BIO 251','bio150','BIO 150',false),
  ('BIO 251','chm129','CHM 129',false),
  ('BIO 251','chm221','CHM 221',true),
  ('BIO 252','bio251','BIO 251',false),
  ('BIO 252','math','MAT 124',false),
  ('BIO 252','math','MAT 131',false)
) AS v(course_code, group_code, prerequisite_code, can_be_corequisite)
JOIN courses course ON course.course_code = v.course_code
JOIN courses prereq ON prereq.course_code = v.prerequisite_code
ON CONFLICT DO NOTHING;

-- ------------------------------------------------------------
-- 3) Core Requirements
-- ------------------------------------------------------------

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BIO_CORE_150', 'BIO 150', 'must_take', 10
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BIO_CORE_251', 'BIO 251', 'must_take', 20
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BIO_CORE_252', 'BIO 252', 'must_take', 30
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 4) Additional Biology Credits
-- ------------------------------------------------------------
-- 20 credits of 200-level or higher BIO, or BCM 262
-- With extra rules:
--   - at least 12 credits at 300-level or higher
--   - at least 12 credits with lab
--   - at least 12 credits must be Grinnell courses
--   - not more than 5 credits from BIO 297/299/397/399/499/SCI 300 or independent study elsewhere
--   - with prior approval, up to 4 credits from approved related-field list may apply
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'BIO_ADDITIONAL_20',
       'Additional Courses: 20 credits of 200-level+ Biology or BCM 262',
       'custom',
       20,
       'Need 20 credits of BIO 200-level or higher elective work, or BCM 262. At least 12 credits must be 300-level or higher, at least 12 credits must include a lab component, at least 12 credits must be Grinnell courses. Not more than 5 credits may come from BIO 297/299/397/399/499, SCI 300, or independent study elsewhere. With prior approval, up to 4 credits from ANT 221, NRS 250, or PSY 336 may count.',
       40
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 5) Also Required
-- ------------------------------------------------------------

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BIO_REQ_CHM129', 'CHM 129', 'must_take', 50
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'BIO_REQ_CHM221', 'CHM 221', 'must_take', 60
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

INSERT INTO requirement_blocks(major_id, code, title, rule_type, min_count, notes, sort_order)
SELECT m.id, 'BIO_REQ_MATH', 'MAT 124 or MAT 131', 'choose_one', 1,
       'Complete MAT 124 or MAT 131.',
       70
FROM majors m
WHERE m.code = 'BIO'
ON CONFLICT (major_id, code) DO NOTHING;

-- ------------------------------------------------------------
-- 6) Attach course options
-- ------------------------------------------------------------

-- BIO 150
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'BIO 150'
WHERE m.code = 'BIO'
  AND b.code = 'BIO_CORE_150'
ON CONFLICT DO NOTHING;

-- BIO 251
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'BIO 251'
WHERE m.code = 'BIO'
  AND b.code = 'BIO_CORE_251'
ON CONFLICT DO NOTHING;

-- BIO 252
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'BIO 252'
WHERE m.code = 'BIO'
  AND b.code = 'BIO_CORE_252'
ON CONFLICT DO NOTHING;

-- CHM 129
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CHM 129'
WHERE m.code = 'BIO'
  AND b.code = 'BIO_REQ_CHM129'
ON CONFLICT DO NOTHING;

-- CHM 221
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'CHM 221'
WHERE m.code = 'BIO'
  AND b.code = 'BIO_REQ_CHM221'
ON CONFLICT DO NOTHING;

-- MAT 124 or MAT 131
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('MAT 124','MAT 131')
WHERE m.code = 'BIO'
  AND b.code = 'BIO_REQ_MATH'
ON CONFLICT DO NOTHING;

COMMIT;
