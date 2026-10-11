
/* ---------- STEP 1: populate companies (dimension) ---------- */
INSERT INTO dbo.companies (company_id, company_name)
SELECT ROW_NUMBER() OVER (ORDER BY company_name) AS company_id, company_name
FROM (SELECT DISTINCT company_name FROM dbo.raw_staging) AS c;


/* ---------- STEP 2: populate job_titles (dimension) ----------
   Splitting "Senior Data Analyst" into base_role = "Data Analyst"
   + seniority_level = "Senior"
*/
INSERT INTO dbo.job_titles (job_title_id, job_title, base_role, seniority_level)
SELECT
    ROW_NUMBER() OVER (ORDER BY job_title) AS job_title_id,
    job_title,
    CASE WHEN job_title LIKE 'Senior %'
         THEN REPLACE(job_title, 'Senior ', '')
         ELSE job_title END AS base_role,
    CASE WHEN job_title LIKE 'Senior %'
         THEN 'Senior' ELSE 'Standard' END AS seniority_level
FROM (SELECT DISTINCT job_title FROM dbo.raw_staging) AS jt;


/* ---------- STEP 3: populate salary_benchmarks (fact table) ----------
   Salary columns are already numeric (MONEY) — just cast to DECIMAL.
*/
INSERT INTO dbo.salary_benchmarks
    (record_id, company_id, job_title_id, min_experience,
     avg_salary_lpa, min_salary_lpa, max_salary_lpa, salary_range_lpa, num_of_salaries)
SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS record_id,
    c.company_id,
    jt.job_title_id,
    s.min_experience,
    CAST(s.avg_salary AS DECIMAL(6,1)) AS avg_salary_lpa,
    CAST(s.min_salary AS DECIMAL(6,1)) AS min_salary_lpa,
    CAST(s.max_salary AS DECIMAL(6,1)) AS max_salary_lpa,
    CAST(s.max_salary AS DECIMAL(6,1)) - CAST(s.min_salary AS DECIMAL(6,1)) AS salary_range_lpa,
    s.num_of_salaries
FROM dbo.raw_staging s
JOIN dbo.companies c   ON c.company_name = s.company_name
JOIN dbo.job_titles jt ON jt.job_title = s.job_title;


/* ---------- STEP 4: sanity check ---------- */
SELECT COUNT(*) AS companies_loaded FROM dbo.companies;         -- expect 642
SELECT COUNT(*) AS job_titles_loaded FROM dbo.job_titles;        -- expect 10
SELECT COUNT(*) AS benchmarks_loaded FROM dbo.salary_benchmarks; -- expect 1602

-- Career ladder check — should show Data Analyst ~5.7, Senior ~9.6,
-- Business Analyst ~8.9, Senior ~13.2, Data Scientist ~13.5, Senior ~22.3
SELECT jt.base_role, jt.seniority_level, CAST(AVG(sb.avg_salary_lpa) AS DECIMAL(5,1)) AS avg_salary_lpa
FROM dbo.salary_benchmarks sb
JOIN dbo.job_titles jt ON jt.job_title_id = sb.job_title_id
GROUP BY jt.base_role, jt.seniority_level
ORDER BY avg_salary_lpa;


select * from companies
select * from job_titles
select * from salary_benchmarks
