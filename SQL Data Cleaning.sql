-- DATA CLEANING 

-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA 	
-- 3. NULL AND BLANK VALUES
-- 4. REMOVE ANY UNNECESSARY COLUMNS

SELECT *
FROM layoffs
;

CREATE TABLE layoff_staging
LIKE layoffs;

SELECT *
FROM layoff_staging
;

INSERT layoff_staging
SELECT *
FROM layoffs  
; 


SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off,percentage_laid_off,`date`) AS row_num 
FROM layoff_staging
; -- tagging duplicates with a row number so you can later filter out extras and keep just one of each.



SELECT *
FROM layoff_staging
WHERE row_num >1 
; -- getting error, reason - You can’t use row_num in WHERE directly because it doesn’t exist at that point. Wrap your logic in a subquery or CTE to filter on it


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1 
;

-- to check whether he returned data are really duplicates 
SELECT *
FROM layoff_staging
WHERE company = 'yahoo'
;

-- YOU CANNOT UPDATE A CTE

CREATE TABLE `layoff_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoff_staging3
WHERE row_num > 1;

INSERT INTO layoff_staging3
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoff_staging
;

DELETE 
FROM layoff_staging3
WHERE row_num > 1;


-- 2.STANDARDIZZING THE DATA 
SELECT *
FROM layoff_staging3
;


SELECT company, TRIM(company) 
FROM layoff_staging3
; -- TRIM REMOVES ALL THE WHITE SPACES OF THE END BOTH RIGHT AND LEFT SIDE

UPDATE layoff_staging3
SET company = TRIM(company)
; 

SELECT *
FROM layoff_staging3
WHERE industry LIKE 'Crypto%'
;

UPDATE layoff_staging3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoff_staging3
ORDER BY 1
;

UPDATE layoff_staging3
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE  'United States%'
;

SELECT country 
FROM layoff_staging3
WHERE country LIKE  'United States%'
;

SELECT `date`
FROM layoff_staging3
;

UPDATE layoff_staging3
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y')
;


ALTER TABLE layoff_staging3
MODIFY COLUMN `date` DATE;


SELECT *
FROM layoff_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL 
;

SELECT * 
FROM layoff_staging3 
WHERE company = 'Airbnb'
;

UPDATE layoff_staging3
SET industry = NULL
WHERE industry = ''
;


SELECT *
FROM layoff_staging3 AS t1
JOIN layoff_staging3 AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

UPDATE layoff_staging3 AS t1
JOIN layoff_staging3 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;


SELECT *
FROM layoff_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL 
;

DELETE 
FROM layoff_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

ALTER TABLE layoff_staging3
DROP COLUMN row_num;


SELECT *
FROM layoff_staging3;