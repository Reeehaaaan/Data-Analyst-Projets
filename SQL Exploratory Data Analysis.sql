-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoff_staging3
;

SELECT *
FROM layoff_staging3
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

SELECT company ,SUM(total_laid_off)
FROM layoff_staging3
GROUP BY company
ORDER BY 2 DESC
;

SELECT MIN(date), MAX(date)
FROM layoff_staging3;

SELECT industry, SUM(total_laid_off)
FROM layoff_staging3
GROUP BY industry
ORDER BY 2 DESC
;

SELECT country, SUM(total_laid_off)
FROM layoff_staging3
GROUP BY country 
ORDER BY 2 DESC
;

SELECT YEAR(`DATE`), SUM(total_laid_off)
FROM layoff_staging3 
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

SELECT stage, SUM(total_laid_off)
FROM layoff_staging3
GROUP BY stage
ORDER BY 2 DESC
;

WITH rolling_total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoff_staging3
WHERE  SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month` 
ORDER BY 1 ASC
)
SELECT `month` ,total_off,SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total
;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging3
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

WITH Company_Year (company,years,totaL_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging3
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS company_ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE company_ranking <=5
;

