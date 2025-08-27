-- Exploratory Data Analysis

SELECT
	percentage_laid_off
FROM dbo.layoffs_staging
order by  1


SELECT
	MAX(total_laid_off), MAX(percentage_laid_off)
FROM dbo.layoffs_staging

-- Change data type of [percentage_laid_off] to float
ALTER TABLE dbo.layoffs_staging
ALTER COLUMN percentage_laid_off float

-- Convert all nulls or empty strings of [funds_raised_millions] columns real NULL.
-- Change data type to float.
UPDATE dbo.layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions IS NULL OR funds_raised_millions = '' OR funds_raised_millions = 'NULL';

ALTER TABLE dbo.layoffs_staging
ALTER COLUMN funds_raised_millions FLOAT;

SELECT
	*
FROM dbo.layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT
	company, SUM(total_laid_off)
FROM dbo.layoffs_staging
GROUP BY company
ORDER BY 2 DESC;

SELECT
	MIN([date]), MAX([date])
FROM dbo.layoffs_staging;

SELECT
	industry, SUM(total_laid_off)
FROM dbo.layoffs_staging
GROUP BY industry
ORDER BY 2 DESC;

SELECT
	country, SUM(total_laid_off)
FROM dbo.layoffs_staging
GROUP BY country
ORDER BY 2 DESC;

SELECT
	DATEPART(YEAR, [date]), SUM(total_laid_off),
FROM dbo.layoffs_staging
GROUP BY DATEPART(YEAR, [date])
ORDER BY 1 DESC;


--layoffs by  year and month
SELECT
	FORMAT([date],'yyyy-MM') AS YearMonth,
	SUM(total_laid_off)
FROM dbo.layoffs_staging
WHERE FORMAT([date],'yyyy-MM') IS NOT NULL
GROUP BY FORMAT([date],'yyyy-MM')
ORDER BY 1 ASC;


-- Rolling total

WITH Rolling_Total AS(
	SELECT
	TOP 100 PERCENT
		FORMAT([date],'yyyy-MM') AS YearMonth,
		SUM(total_laid_off) AS Total_Layoffs
	FROM dbo.layoffs_staging
	WHERE FORMAT([date],'yyyy-MM') IS NOT NULL
	GROUP BY FORMAT([date],'yyyy-MM')
	ORDER BY 1 ASC
)
SELECT
	YearMonth,
	Total_Layoffs,
	SUM(Total_Layoffs) OVER(ORDER BY YearMonth ROWS UNBOUNDED PRECEDING) AS rolling_total	
FROM Rolling_Total;


-- Layoffs by company and years
SELECT
	company,
	YEAR([date]),
	SUM(total_laid_off)
FROM dbo.layoffs_staging
GROUP BY company, YEAR([date])
ORDER BY 3 DESC;


WITH company_year(company, years, total_laid_off) AS(
	SELECT
		company,
		YEAR([date]),
		SUM(total_laid_off)
	FROM dbo.layoffs_staging
	GROUP BY company, YEAR([date])
),
company_ranking AS(
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS rank_layoff
	FROM company_year
	WHERE years IS NOT NULL
)
SELECT
	*
FROM company_ranking
WHERE rank_layoff <=5;