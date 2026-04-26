
-- ============================================================
-- History (HIS)
-- ============================================================
 
-- ------------------------------------------------------------
-- 1) Major
-- ------------------------------------------------------------
INSERT INTO majors(code, name)
VALUES ('HIS', 'History')
ON CONFLICT (code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 2) Courses
-- ------------------------------------------------------------
INSERT INTO courses(dept, number, course_code, title, credits) VALUES
-- Core
('HIS',100,'HIS 100','Introduction to Historical Inquiry',4),
 
-- Latin American History (20X)
('HIS',201,'HIS 201','Latin American History I',4),
('HIS',202,'HIS 202','Latin American History II',4),
('HIS',203,'HIS 203','Topics in Latin American History',4),
 
-- US History (21X, 22X)
('HIS',210,'HIS 210','United States History I',4),
('HIS',211,'HIS 211','United States History II',4),
('HIS',212,'HIS 212','Topics in US History',4),
('HIS',220,'HIS 220','US Social History',4),
('HIS',221,'HIS 221','US Cultural History',4),
('HIS',222,'HIS 222','Topics in US History II',4),
 
-- European History (23X, 25X)
('HIS',230,'HIS 230','European History I',4),
('HIS',231,'HIS 231','European History II',4),
('HIS',232,'HIS 232','Topics in European History',4),
('HIS',250,'HIS 250','Modern Europe',4),
('HIS',251,'HIS 251','Topics in Modern European History',4),
 
-- Russian History (24X)
('HIS',240,'HIS 240','Russian History I',4),
('HIS',241,'HIS 241','Russian History II',4),
 
-- History of Africa and the Middle East (26X)
('HIS',260,'HIS 260','African History',4),
('HIS',261,'HIS 261','History of the Middle East',4),
('HIS',262,'HIS 262','Topics in African and Middle Eastern History',4),
 
-- Asian History (27X)
('HIS',270,'HIS 270','Asian History I',4),
('HIS',271,'HIS 271','Asian History II',4),
('HIS',277,'HIS 277','China''s Rise',4),
 
-- Transregional and Comparative History (28X)
('HIS',280,'HIS 280','World History',4),
('HIS',281,'HIS 281','Transregional Topics',4),
('HIS',282,'HIS 282','Comparative History',4),
 
-- 300-level Seminars
('HIS',300,'HIS 300','Advanced Seminar in History I',4),
('HIS',301,'HIS 301','Advanced Seminar in History II',4),
('HIS',310,'HIS 310','Seminar in US History',4),
('HIS',320,'HIS 320','Seminar in European History',4),
('HIS',330,'HIS 330','Seminar in World/Comparative History',4),
('HIS',340,'HIS 340','Seminar in Asian History',4),
('HIS',350,'HIS 350','Seminar in African/Middle Eastern History',4),
('HIS',360,'HIS 360','Seminar in Latin American History',4),
('HIS',370,'HIS 370','Seminar in Russian History',4)
 
ON CONFLICT (course_code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 3) Core: HIS 100
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(major_id, code, title, rule_type, sort_order)
SELECT m.id, 'HIS_CORE_100', 'HIS 100 Introduction to Historical Inquiry', 'must_take', 10
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 4) Geographic Distribution: 3 regions at 200-level (12 credits)
-- ------------------------------------------------------------
 
-- Region A: Latin American History (20X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_LATAM',
       '200-level Region: Latin American History (20X)',
       'choose_one',
       1,
       'Choose one 200-level course in Latin American history (HIS 20X series).',
       20
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region B: US History (21X, 22X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_US',
       '200-level Region: US History (21X, 22X)',
       'choose_one',
       1,
       'Choose one 200-level course in US history (HIS 21X or 22X series).',
       21
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region C: European History (23X, 25X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_EUROPE',
       '200-level Region: European History (23X, 25X)',
       'choose_one',
       1,
       'Choose one 200-level course in European history (HIS 23X or 25X series).',
       22
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region D: Russian History (24X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_RUSSIA',
       '200-level Region: Russian History (24X)',
       'choose_one',
       1,
       'Choose one 200-level course in Russian history (HIS 24X series).',
       23
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region E: Africa and Middle East (26X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_AFRICA_ME',
       '200-level Region: Africa and Middle East (26X)',
       'choose_one',
       1,
       'Choose one 200-level course in African or Middle Eastern history (HIS 26X series).',
       24
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region F: Asian History (27X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_ASIA',
       '200-level Region: Asian History (27X)',
       'choose_one',
       1,
       'Choose one 200-level course in Asian history (HIS 27X series).',
       25
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Region G: Transregional and Comparative (28X)
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_REGION_TRANS',
       '200-level Region: Transregional and Comparative History (28X)',
       'choose_one',
       1,
       'Choose one 200-level course in transregional or comparative history (HIS 28X series).',
       26
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- Geographic distribution summary: must cover 3 distinct regions
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_count, notes, sort_order
)
SELECT m.id,
       'HIS_GEO_DISTRIBUTION',
       'Geographic Distribution: 3 different regions at 200-level (12 credits)',
       'custom',
       3,
       'Must take 200-level courses covering at least 3 different geographic regions from: Latin American (20X), US (21X/22X), European (23X/25X), Russian (24X), Africa/Middle East (26X), Asian (27X), Transregional/Comparative (28X). Each region course is 4 credits; total 12 credits.',
       30
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 5) 300-level Seminars: 2 courses by different professors (8 credits)
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'HIS_300_SEMINARS',
       '300-level Seminars: 2 courses by different professors (8 credits)',
       'custom',
       8,
       'Must complete two 300-level history seminars (8 credits), each taught by a different professor. Both must be taken at Grinnell College.',
       40
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 6) Additional History Courses: 8 credits
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'HIS_ADDITIONAL',
       'Additional History Courses: 8 credits',
       'custom',
       8,
       'Eight additional credits of history coursework. With permission, up to 4 credits may be taken in related studies outside the department, and/or up to 8 credits may come from approved off-campus study.',
       50
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 7) Grinnell residency requirement
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'HIS_GRINNELL_MIN',
       'Grinnell residency: at least 20 of 32 credits at Grinnell',
       'custom',
       20,
       'At least 20 of the 32 required major credits must be earned within the History Department at Grinnell College. Both required 300-level seminars must be taken at Grinnell.',
       60
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 8) Overall totals
-- ------------------------------------------------------------
INSERT INTO requirement_blocks(
  major_id, code, title, rule_type, min_credits, notes, sort_order
)
SELECT m.id,
       'HIS_TOTALS',
       'Major totals and policy constraints',
       'custom',
       32,
       'Minimum 32 credits with a grade of C or higher: 4 credits HIS 100 + 12 credits geographic distribution (3 regions) + 8 credits 300-level seminars (2 different professors) + 8 credits additional history courses. At least 20 credits must be at Grinnell. Up to 4 credits in related studies and/or up to 8 OCS credits allowed with permission. Department recommends chronological diversity (at least one course before 1850, one after 1850), one quantitative analysis course, and language study.',
       70
FROM majors m
WHERE m.code = 'HIS'
ON CONFLICT (major_id, code) DO NOTHING;
 
-- ------------------------------------------------------------
-- 9) Attach course options
-- ------------------------------------------------------------
 
-- Core: HIS 100
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code = 'HIS 100'
WHERE m.code = 'HIS' AND b.code = 'HIS_CORE_100'
ON CONFLICT DO NOTHING;
 
-- Latin American (20X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('HIS 201','HIS 202','HIS 203')
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_LATAM'
ON CONFLICT DO NOTHING;
 
-- US History (21X, 22X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'HIS 210','HIS 211','HIS 212','HIS 220','HIS 221','HIS 222'
)
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_US'
ON CONFLICT DO NOTHING;
 
-- European History (23X, 25X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'HIS 230','HIS 231','HIS 232','HIS 250','HIS 251'
)
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_EUROPE'
ON CONFLICT DO NOTHING;
 
-- Russian History (24X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('HIS 240','HIS 241')
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_RUSSIA'
ON CONFLICT DO NOTHING;
 
-- Africa and Middle East (26X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('HIS 260','HIS 261','HIS 262')
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_AFRICA_ME'
ON CONFLICT DO NOTHING;
 
-- Asian History (27X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('HIS 270','HIS 271','HIS 277')
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_ASIA'
ON CONFLICT DO NOTHING;
 
-- Transregional and Comparative (28X)
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN ('HIS 280','HIS 281','HIS 282')
WHERE m.code = 'HIS' AND b.code = 'HIS_REGION_TRANS'
ON CONFLICT DO NOTHING;
 
-- 300-level seminars
INSERT INTO block_course_options(block_id, course_id)
SELECT b.id, c.id
FROM requirement_blocks b
JOIN majors m ON m.id = b.major_id
JOIN courses c ON c.course_code IN (
  'HIS 300','HIS 301','HIS 310','HIS 320','HIS 330',
  'HIS 340','HIS 350','HIS 360','HIS 370'
)
WHERE m.code = 'HIS' AND b.code = 'HIS_300_SEMINARS'
ON CONFLICT DO NOTHING;
 
COMMIT;
 