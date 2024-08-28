

# DATA CLEANING 

# 1. REMOVE DUPLICATES
# 2. STANDARIZED DATA
# 3. NULL VALUES / BLANK VALUES
# 4. REMOVE ANY COLUMNS

# Create table to work apart from row data table.
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

-- 1. Remove Duplicates
SELECT * FROM layoffs_staging;

# By using window function we can identify duplicates row based on their columns/
# If row_num is greater than 1 it means the data is duplicated.
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 			funds_raised) AS row_num
FROM layoffs_staging;

# I create a CTE work with duplicates
WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 			funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

# We identified that a company called "included Health" is duplicated three times.
SELECT * FROM layoffs_staging
WHERE company LIKE " Included Health";


#Due to a CTE is not updatable, I create another table to add the a columns that works as identified of duplicates. Then, insert the query result as the duplicate_cte 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL,
  `row_num` INT #New column
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, 		funds_raised)
FROM layoffs_staging;

#Checking  insertion and removing duplicates
SELECT * FROM layoffs_staging2;

DELETE 
FROM layoffs_staging2
WHERE row_num >1;

#As after running the deletion query the select one does not retrieve a single row, the process of removing duplicate has been done properly.
SELECT * 
FROM layoffs_staging2
WHERE row_num >1;
# The company "Included Health" that appears three times layoffs_staging appears only once in layoffs_staging2 
SELECT * FROM layoffs_staging2
WHERE company LIKE " Included Health";



-- 2. STANDARIZING DATA

SELECT * FROM layoffs_staging2;

#Checking company column

SELECT DISTINCT company FROM layoffs_staging2;
-- We could identify some blank spaces at the beggining of company name

#Query to check if trim function will work as desired
SELECT company, TRIM(company)
FROM layoffs_staging2;
#Updating table to remove blank spaces
UPDATE layoffs_staging2
SET company = TRIM(company);



#Checking location column
SELECT DISTINCT location
FROM layoffs_staging2;
-- Column data looks fine

#Checking industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


#Checking country column
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

#Checking `date` column 
-- As the data is properly formmated 'yyyy-mm-dd' we may alter the table datatype
SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. NULL/BLANK VALUES

#Checking null values in industry column
SELECT *
FROM layoffs_staging2
ORDER BY industry;
-- 'Appsmith' company industries data is empty. We may check if there's more rows populated data  of the company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Appsmith';
	-- As the company appears once we may not identify via the database the company's industry
    

-- 4. REMOVE ANY INNECESARY COLUMN / ROWS  
# There are several rows that are empty in 'total_laid_off' and 'percentage_laid_off'. Due to analysis purposes, we may rid of those rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = "" AND percentage_laid_off ="";

DELETE
FROM layoffs_staging2
WHERE total_laid_off = "" AND percentage_laid_off ="";


#As we have come up with a new column called "row_num" that was used as temporary 'identifier' of duplocated data its deletion is benefitial in terms of reducing query response times
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
