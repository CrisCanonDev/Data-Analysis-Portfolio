-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

#Checking the maximum and minimum amount of workers laid off historically
SELECT MAX(total_laid_off), MIN(total_laid_off)
FROM layoffs_staging2;

#Checking range of dates when data is has been taken
SELECT MAX(date), MIN(date)
FROM layoffs_staging2;
	-- The data goes from 11th January 2020 to 9th August 2024

#Checking amount of workers laid off per company
SELECT company, SUM(total_laid_off) as `total laid off`
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
	-- Company as Amazon and meta leads the laid off amount.
    
#Checking ranking of industries
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
	-- Retail and consumer industries lead the ranking
    
#Checking countries ranking
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
	-- The United Stated leads the countries list with a wide gap among the rest.

#Checking amount of laid offs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
	-- 2023 lead the ranking of years by laid off.
    
#Checking the amount of laid offs per month
SELECT SUBSTRING(`date`,1,7), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY 1 DESC;


#Adding the amount of workers laid off per month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY 1 DESC
)
SELECT `Month`, total_off, 
SUM(total_off) OVER(ORDER BY `Month`) as rolling_total 	
FROM Rolling_total;
	-- 1. Through a CTE I queried by month the amount of laid offs
    -- 2. Via window function we come up with the amount of 560757 workers laid offs


#Checking companies laid off per year
SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) as "Laid off"
FROM layoffs_staging2
GROUP BY company, YEAR(`date`);


#Ranking the top 4 companies with more workers laid off per year
WITH Company_year (company, `year`, laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_ranking AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY laid_off DESC) AS ranking
FROM Company_year
)
SELECT *
FROM Company_ranking
WHERE ranking < 5;
	-- 1. We have used two CTEs. The first CTE queries the amount of laid off per company and year.
    -- 2. The second CTE queries the rank via DENSE_RANK to rank those companies laid offs
    -- Finally, I filter the resulted query limiting it by the top 4 yearly.