-- Data Cleaning

SELECT
	*
FROM dbo.layoffs;

-- Preserve raw data and create another table
SELECT TOP 0 *
INTO dbo.layoffs_staging
FROM dbo.layoffs;


SELECT
	*
FROM dbo.layoffs_staging;


-- Insert all data to new table
INSERT INTO dbo.layoffs_staging
SELECT *
FROM dbo.layoffs;


-- Remove Duplicates
-- Since there's no unique values we look for each column.

WITH duplicate_rows AS(
	SELECT
		*,
		ROW_NUMBER() OVER(
		PARTITION BY company, [location], industry, total_laid_off, percentage_laid_off, [date], stage,
		country, funds_raised_millions ORDER BY (SELECT NULL)) AS Row_Num
	FROM dbo.layoffs_staging
)
DELETE
FROM duplicate_rows
WHERE Row_Num > 1;



-- Standardizing Data

SELECT
	company, TRIM(company)
FROM dbo.layoffs_staging;

UPDATE dbo.layoffs_staging
SET company = TRIM(company);


SELECT
	DISTINCT industry
FROM dbo.layoffs_staging
ORDER BY industry ASC;

SELECT
	*
FROM dbo.layoffs_staging
WHERE industry LIKE 'Crypto%'

UPDATE dbo.layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT
	DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM dbo.layoffs_staging
ORDER BY 1;

UPDATE dbo.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT
	*
FROM dbo.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL


-- When importing excel files into such database, data type might be corrupted.
-- Sometimes nulls can be transformed as string NULLs.
SELECT
	*
FROM dbo.layoffs_staging
WHERE industry IS NULL
OR industry = ''
OR industry = 'NULL'


SELECT
	*
FROM dbo.layoffs_staging
WHERE company = 'Airbnb';


-- Filling null values for [industry]' with corresponding ones.
-- First change all blank and null strings to NULL. Then update it.
SELECT
	*
FROM dbo.layoffs_staging ls1
JOIN dbo.layoffs_staging ls2
	ON ls1.company = ls2.company	
WHERE (ls1.industry IS NULL OR ls1.industry = '')
AND ls2.industry IS NOT NULL;


UPDATE dbo.layoffs_staging
SET industry = NULL
WHERE industry = '' or industry = 'NULL'


UPDATE ls1
SET ls1.industry = ls2.industry
FROM dbo.layoffs_staging AS ls1
JOIN dbo.layoffs_staging AS ls2
	ON ls1.company = ls2.company
WHERE ls1.industry IS NULL
AND ls2.industry IS NOT NULL;


SELECT
	*
FROM dbo.layoffs_staging;


-- Delete rows where both [total_laid_off] and [percentage_laid_off] are empty
SELECT
	*
FROM dbo.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT
	*
FROM dbo.layoffs_staging
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '' OR percentage_laid_off = 'NULL';

UPDATE dbo.layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '' OR percentage_laid_off = 'NULL';

DELETE
FROM dbo.layoffs_staging 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;






















