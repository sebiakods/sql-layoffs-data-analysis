USE world_layoffs;



-- STEP 0: Inspect the raw data
SELECT COUNT(*) AS total_rows
FROM layoffs;

SELECT *
FROM layoffs;



-- STEP 1: Create a staging table to protect the raw data
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;



-- STEP 2: Remove duplicates
-- Number identical rows using every column; row_num > 1 means duplicate
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   company,
                   location,
                   industry,
                   total_laid_off,
                   percentage_laid_off,
                   `date`,
                   stage,
                   country,
                   funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Manually check one company to confirm the duplicates are real
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- MySQL cannot DELETE from a CTE, so use a second staging table with a row_num column
DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Fill the new table with the data plus the computed row_num
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Disable safe update mode so UPDATE/DELETE without a key is allowed
SET SQL_SAFE_UPDATES = 0;

-- Delete the duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Verify: this should return no rows
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;





-- STEP 3: Standardize the data
-- Remove leading and trailing spaces from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Merge Crypto variants (Crypto Currency, CryptoCurrency...) into one value
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Remove the trailing period in "United States."
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert text dates to real dates (format month/day/year)
-- Text 'NULL' values are turned into real NULLs first
UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'NULL';

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

-- Change the column type from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- STEP 4: Handle NULL values and blanks
-- Convert blank industries to NULL so they are handled consistently
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industries from another row of the same company and location
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;





-- STEP 5: Remove unnecessary rows and columns

-- Delete rows with no layoff information at all
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Drop the helper column used for duplicate detection
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM layoffs_staging2;





-- formation date column 

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

SET SQL_SAFE_UPDATES = 0;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> 'NULL';

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;







-- data cleaning 
SELECT *
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


select distinct industry
FROM layoffs_staging2
where industry = '';


SELECT t1.industry , t2.industry
FROM layoffs_staging2  as t1
join  layoffs_staging2  as t2
	 on t1.company=t2.company
	 and t1.location=t2.location
where (t1.industry is null  or t1.industry ='')
and t2.industry is not null;
 
update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company=t2.company
set t1.industry = t2.industry
where (t1.industry is null  or t1.industry ='')
and t2.industry is not null;
 
 
SELECT *
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;













