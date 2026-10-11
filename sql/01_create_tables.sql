/* ============================================================
   create_tables.sql (v2 — real dataset)
   India Data & Analytics Salary Benchmark Dashboard
   Source: "Data Science Jobs In India" (Kaggle, scraped from AmbitionBox)

   Load order: companies -> job_titles -> salary_benchmarks
   ============================================================ */

CREATE TABLE dbo.companies (
    company_id      INT PRIMARY KEY,
    company_name    VARCHAR(150) NOT NULL
);

CREATE TABLE dbo.job_titles (
    job_title_id    INT PRIMARY KEY,
    job_title       VARCHAR(50) NOT NULL,
    base_role       VARCHAR(50) NOT NULL,   -- e.g. "Data Analyst"
    seniority_level VARCHAR(20) NOT NULL    -- "Senior" or "Standard"
);

CREATE TABLE dbo.salary_benchmarks (
    record_id          INT PRIMARY KEY,
    company_id          INT NOT NULL REFERENCES dbo.companies(company_id),
    job_title_id         INT NOT NULL REFERENCES dbo.job_titles(job_title_id),
    min_experience        INT NOT NULL,
    avg_salary_lpa        DECIMAL(6,1) NOT NULL,
    min_salary_lpa        DECIMAL(6,1) NOT NULL,
    max_salary_lpa        DECIMAL(6,1) NOT NULL,
    salary_range_lpa       DECIMAL(6,1) NOT NULL,
    num_of_salaries        INT NOT NULL   -- sample size behind this benchmark
);

SELECT * FROM dbo.salary_benchmarks;
SELECT * FROM dbo.job_titles;



select count(*) from raw_staging;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_staging';

SELECT TOP 5 * FROM dbo.raw_staging;

select * from raw_staging
