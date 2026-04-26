BEGIN;
 
-- ============================================================
-- Sociology (SOC)
-- ============================================================
 
-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('SOC', 'Sociology')
ON CONFLICT (code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
-- Core
('SOC',111,'SOC 111','Introduction to Sociology',4),
('SOC',285,'SOC 285','Contemporary Sociological Theory',4),
('SOC',291,'SOC 291','Methods of Empirical Investigation',4),
('ANT',291,'ANT 291','Methods of Empirical Investigation (cross-listed)',4),
 
-- 300-level courses (eligible; excludes SOC 300, 397, 399, 499)
('SOC',301,'SOC 301','Social Inequality',4),
('SOC',310,'SOC 310','Medical Sociology',4),
('SOC',315,'SOC 315','Sociology of Deviance',4),
('SOC',320,'SOC 320','Political Sociology',4),
('SOC',325,'SOC 325','Race, Class, and Gender',4),
('SOC',340,'SOC 340','Urban Sociology',4),
('SOC',350,'SOC 350','Advanced Topics in Sociology',4),
('SOC',360,'SOC 360','Sociology of Organizations',4),
('SOC',370,'SOC 370','Environmental Sociology',4),
('SOC',380,'SOC 380','Global Sociology',4),
 
-- Ineligible 300-level (listed for reference; must not count toward 300-level req)
('SOC',300,'SOC 300','Special Topics (ineligible for 300-level requirement)',4),
('SOC',397,'SOC 397','Special Studies (ineligible for 300-level requirement)',4),
('SOC',399,'SOC 399','Mentored Advanced Project (ineligible for 300-level requirement)',4),
('SOC',499,'SOC 499','Senior Thesis (ineligible for 300-level requirement)',4),
 
-- 200-level electives
('SOC',230,'SOC 230','Criminology',4),
('SOC',240,'SOC 240','Family and Society',4),
('SOC',250,'SOC 250','Work and Organizations',4),
('SOC',260,'SOC 260','Human Sexuality in the United States',4),
('SOC',270,'SOC 270','Gender and Society',4),
('SOC',280,'SOC 280','Religion and Society',4),
('SOC',295,'SOC 295','Special Topics',4),
 
-- Math / Statistics
('SST',115,'SST 115','Introduction to Statistics',4),
('STA',209,'STA 209','Applied Statistics',4),
('MAT',336,'MAT 336','Probability and Statistics II',4)
 
ON CONFLICT (course_code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 3) Core: SOC 111
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'SOC_CORE_111', 'SOC 111 Introduction to Sociology', 'must_take', 10
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 4) Core: SOC 285
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'SOC_CORE_285', 'SOC 285 Contemporary Sociological Theory', 'must_take', 20
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 5) Core: SOC 291 or ANT 291
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'SOC_CORE_291',
       'SOC 291 or ANT 291 Methods of Empirical Investigation',
       'choose_one',
       1,
       'Complete SOC 291 or the cross-listed ANT 291.',
       30
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 6) Core summary: 12 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'SOC_CORE_SUMMARY',
       'Core summary: 12 credits',
       'custom',
       12,
       'Core consists of SOC 111, SOC 285, and SOC 291 (or ANT 291). Normally SOC 111 and the statistics requirement should be completed by the second year, and SOC 285 and SOC 291 by the end of the third year.',
       40
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 7) 300-level requirement: 8 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'SOC_300_LEVEL',
       '300-level Courses: 8 credits',
       'custom',
       8,
       'Eight credits must be taken at the 300-level or above. All SOC 300-level courses count EXCEPT SOC 300, SOC 397, SOC 399, and SOC 499.',
       50
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 8) Sociology Electives: 12 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'SOC_ELECTIVES',
       'Sociology Electives: 12 credits',
       'custom',
       12,
       'Twelve elective credits in Sociology. Approved off-campus study courses listed as Sociology or Social Studies may count, but no more than 4 such credits may apply toward the major. Students must petition for OCS cognate approval with syllabus, assignments, and a two-paragraph explanation upon return to campus.',
       60
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 9) Math / Statistics requirement: 4 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'SOC_MATH',
       'Mathematics Requirement: SST 115, STA 209, or MAT 336',
       'choose_one',
       1,
       'Complete one of SST 115 (Introduction to Statistics), STA 209 (Applied Statistics, preferred), or MAT 336 (Probability and Statistics II, preferred).',
       70
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 10) Overall totals
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'SOC_TOTALS',
       'Major totals and policy constraints',
       'custom',
       32,
       'Minimum 32 credits: 12 core + 8 at 300-level + 12 electives. Statistics requirement (4 credits) is part of the 32-credit total. OCS credits capped at 4. SOC 300, 397, 399, and 499 are ineligible for the 300-level requirement.',
       80
FROM majors m
WHERE m.code = 'SOC'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 11) Attach course options
-- ------------------------------------------------------------
 
-- Core: SOC 111
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'SOC 111'
WHERE m.code = 'SOC' AND b.code = 'SOC_CORE_111'
ON CONFLICT DO NOTHING;
 
-- Core: SOC 285
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'SOC 285'
WHERE m.code = 'SOC' AND b.code = 'SOC_CORE_285'
ON CONFLICT DO NOTHING;
 
-- Core: SOC 291 or ANT 291
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('SOC 291','ANT 291')
WHERE m.code = 'SOC' AND b.code = 'SOC_CORE_291'
ON CONFLICT DO NOTHING;
 
-- 300-level eligible courses
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'SOC 301','SOC 310','SOC 315','SOC 320','SOC 325',
  'SOC 340','SOC 350','SOC 360','SOC 370','SOC 380'
)
WHERE m.code = 'SOC' AND b.code = 'SOC_300_LEVEL'
ON CONFLICT DO NOTHING;
 
-- Electives (200-level SOC courses)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'SOC 230','SOC 240','SOC 250','SOC 260',
  'SOC 270','SOC 280','SOC 295'
)
WHERE m.code = 'SOC' AND b.code = 'SOC_ELECTIVES'
ON CONFLICT DO NOTHING;
 
-- Math / Statistics
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('SST 115','STA 209','MAT 336')
WHERE m.code = 'SOC' AND b.code = 'SOC_MATH'
ON CONFLICT DO NOTHING;
 
COMMIT;