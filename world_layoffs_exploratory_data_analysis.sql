SELECT *
FROM layoffs_staging2;


SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2;



SELECT *
FROM layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;


SELECT company, sum(total_laid_off)
FROM layoffs_staging2
group by company
order by 2 desc;


SELECT min('date'), max('date')
FROM layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select year('date'), sum(total_laid_off)
from layoffs_staging2
group by year('date')
order by 2 desc;


select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;


SELECT company, avg(percentage_laid_off)
FROM layoffs_staging2
group by company
order by 2 desc;



select substring('date',1,7)as 'month', sum(total_laid_off)
from layoffs_staging2
group by 'month';


with Rolling_total as
(
select substring('date',1,7)as 'month', sum(total_laid_off)
from layoffs_staging2
group by 'month'
order by 1 asc
)
select 'month', sum(total_off)over(order by 'month')as rolling_total
from Rolling_total;