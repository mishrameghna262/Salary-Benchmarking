/*Q1 — Career ladder: average salary & experience by role and seniority
For each job role and seniority level, what is the average salary, 
average minimum experience, and number of companies reporting it?*/

select jt.base_role,jt.seniority_level, avg(s.avg_salary_lpa) as average_salary,avg(s.min_experience) as average_min_exp,
count(distinct s.company_id) as no_of_companies
from job_titles jt join salary_benchmarks s on jt.job_title_id=s.job_title_id
group by jt.base_role,jt.seniority_level



/*Q2 — Senior salary step-up */

/*For each role that has both Standard and Senior levels, how much higher is the Senior average salary 
compared with the Standard average salary, in percentage terms?*/

with role_avg as(select jt.base_role,jt.seniority_level,avg(s.avg_salary_lpa) as average_salary from job_titles jt
join salary_benchmarks s on jt.job_title_id=s.job_title_id group by jt.base_role,jt.seniority_level)

select a.base_role,a.average_salary as standard_avg,b.average_salary as senior_avg
, (b.average_salary-a.average_Salary)*100/a.average_salary as percentage_increase from 
role_avg a join role_avg b on a.base_role=b.base_role and a.seniority_level='Standard'
and b.seniority_level='Senior'



/*Q3 — Top-paying companies per role
For each job title, which companies have the highest average salaries, 
considering only benchmarks based on at least 10 reported salaries?*/

with cte as(select jt.job_title , c.company_name, avg(s.avg_salary_lpa) as avg_sal 
from salary_benchmarks s join companies c on s.company_id=c.company_id
join job_titles jt on s.job_title_id=jt.job_title_id where s.num_of_salaries>=10 group by jt.job_title,c.company_name 
), 

cte2 as(select job_title, company_name, avg_sal , 
dense_rank() over(partition by job_title order by avg_sal desc) as rank_salaries from cte) 

select * from cte2 where rank_salaries<=3



/*Q4 — Salary spread by role
For each job title, what is the average salary spread (maximum salary − minimum salary),
and what is the average salary?*/

select jt.job_title, avg(s.avg_salary_lpa) as avg_sal ,
avg(max_salary_lpa-min_salary_lpa) as salary_spread from 
job_titles jt join salary_benchmarks s on jt.job_title_id=s.job_title_id
group by jt.job_title

select jt.job_title, avg(s.avg_salary_lpa) as avg_sal, avg(s.salary_range_lpa) as avg_sal_spread
from job_titles jt join salary_benchmarks s on jt.job_title_id=s.job_title_id
group by jt.job_title



/*Q5 — Companies with the most salary data points
Which 15 companies have the most salary data points, and how many different roles do they report?*/

with cte as(select c.company_name,sum(s.num_of_salaries) as salary_observation ,
count(distinct job_title_id) as num_of_roles from companies c join salary_benchmarks s
on c.company_id=s.company_id
group by c.company_name)

select top 15 * from cte order by salary_observation desc


/*Q6 — Business vs Technical role pay
How do business-facing roles compare with technical roles in 
terms of average minimum experience and average salary?*/

with cte as(select job_title_id, case when base_role='Business Analyst' then 'Business Facing' else 'Technical' 
end as roles from job_titles)

select c.roles, avg(s.avg_salary_lpa) as average_Salary , avg(s.min_experience) as minimun_experience from 
cte c join salary_benchmarks s on c.job_title_id=s.job_title_id
group by c.roles


/*Q7 — Salary by experience band
How does average salary vary across different experience bands and base roles ?*/

WITH exp_band AS (
    SELECT jt.base_role,s.company_id, s.avg_salary_lpa,
        CASE
            WHEN s.min_experience <= 1 THEN '0-1'
            WHEN s.min_experience BETWEEN 2 AND 3 THEN '2-3'
            WHEN s.min_experience BETWEEN 4 AND 6 THEN '4-6'
            ELSE '7+yrs'
        END AS salary_band
    FROM job_titles jt
    JOIN salary_benchmarks s
        ON jt.job_title_id = s.job_title_id
)
SELECT base_role, salary_band, AVG(avg_salary_lpa) AS average_salary,COUNT(DISTINCT company_id) AS num_companies
FROM exp_band GROUP BY base_role, salary_band
HAVING COUNT(DISTINCT company_id) >= 5
ORDER BY base_role;



/*Q8 For each job title, how many companies reported salary data for it, 
and what percentage of all 1,602 records does that represent?*/

with cte as(select jt.job_title, count(distinct s.company_id) as cnt  
from job_titles jt join salary_benchmarks s
on jt.job_title_id=s.job_title_id group by jt.job_title)

select job_title, cnt , (cnt*100.0)/(SELECT COUNT(*) FROM salary_benchmarks) as percentage from cte
