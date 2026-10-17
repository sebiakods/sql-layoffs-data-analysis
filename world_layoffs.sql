use world_layoffs;

select COUNT(*) as  total_rows
from  layoffs;



-- cleaning data 
select *
from layoffs;


-- 1 delete duplucations 
-- 2 stabdrize the data
-- 3 null values and blanks
-- 4 delete unecessary colomns 



drop table if exists layoffs_staging ;

create table layoffs_staging 
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging 
 select *
 from layoffs;
 

select *,
       row_number() over (
           partition by
               company,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`
       ) as row_num
from layoffs_staging;
 
 
 with duplicate_cte as 
 (
	select *,
       row_number() over (
           partition by
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
       ) as row_num
from layoffs_staging
 ) 
 select *
 from duplicate_cte
 where 
 row_num>1;
 
 select *
 from  layoffs_staging
 where company='casper';
 
 
 
  with duplicate_cte as 
 (
	select *,
       row_number() over (
           partition by
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
       ) as row_num
from layoffs_staging
 ) 
 delete 
 from duplicate_cte
 where row_num>1;
 
 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

 select *
 from layoffs_staging2 ;
 
 insert into  layoffs_staging2
 select *,
       row_number() over (
           partition by
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
       ) as row_num
from layoffs_staging;




SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;

select *
from layoffs_staging2
where row_num>1;



-- standrize data 
USE world_layoffs;
SELECT company, TRIM(company)
FROM layoffs_staging2;

update layoffs_staging2
set company= trim(company);

SELECT industry, TRIM(industry)
FROM layoffs_staging2;

 select  *
 from layoffs_staging2
where industry  like 'crypto';


update layoffs_staging2
set industry = 'crypto'
where industry like 'crupto%';


 select  distinct country , trim(trailing '.' from country)
  from layoffs_staging2
order by 1 ;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%';
 
 
 select *
 from layoffs_staging2;
 
 
 

