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
