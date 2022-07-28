----------------------------------------------------
-------------- Data Analysis Project --------------
------------------ FEMA Disasters ------------------
----------------- Date: 2022-07-19 -----------------
--------------- By: Larry Hurst III ----------------
----------------------------------------------------
--Tableau URL: https://public.tableau.com/app/profile/larry.hurst5967/viz/FEMA_Disasters/FEMADashboard?publish=yes
----------------------------------------------------
--PART A: DATA NORMALIZATION, FORMATTING, CLEANING--
----------------------------------------------------

--Inspecting the Dataset
SELECT * 
FROM Disasters.dbo.FEMA_DisasterDeclarations
ORDER BY declaration_date asc;

/* 
	After viewing the data, the time is not necessary in date/time fields:

	Requires format standardization of the following 6 date/time fields: 
	(1)declaration_date, (2)incident_begin_date, (3)incident_end_date, 
	(4)disaster_closeout_date, (5)last_ia_filling_date, (6)last_refresh
*/

--(1) Standardizing declaration_date
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET declaration_date = CONVERT(Date,declaration_date);

--(2)Standardizing incident_begin_date
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET incident_begin_date = CONVERT(Date,incident_begin_date)
WHERE incident_begin_date IS NOT NULL;

--(3)Standardizing incident_end_date
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET incident_end_date = CONVERT(Date,incident_end_date)
WHERE incident_end_date IS NOT NULL;

--(4)Standardizing disaster_closeout_date
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET disaster_closeout_date = CONVERT(Date,disaster_closeout_date)
WHERE disaster_closeout_date IS NOT NULL;

--(5)Standardizing last_ia_filing_date
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET last_ia_filing_date = CONVERT(Date,last_ia_filing_date)
WHERE last_ia_filing_date IS NOT NULL;

--(6)Standardizing last_refresh
UPDATE Disasters.dbo.FEMA_DisasterDeclarations 
SET last_refresh = CONVERT(Date,last_refresh)
WHERE last_refresh IS NOT NULL;


---------------------------------------------------
------ PART B: TABLEAU VISUALIZATION QUERIES ------
---------------------------------------------------

--Viz1) United States Map: Incident Totals by State
SELECT state, COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state
ORDER BY total_declarations DESC;

--Viz2) Map tooltip: Most common Incident Type by state
SELECT state, incident_type, COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state, incident_type
ORDER BY state ASC, total_declarations DESC;

--Viz3) Declaration_type totals by state
SELECT state, declaration_type, COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state, declaration_type
ORDER BY state ASC, total_declarations DESC;

--Viz4) Bar Graph: States with >  declarations
SELECT state, COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state 
HAVING COUNT(DISTINCT disaster_number) > 100
ORDER BY total_declarations DESC;

--Viz5) Total declarations by states grouped by incident_type
SELECT state, incident_type, COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state, incident_type
ORDER BY incident_type, total_declarations DESC;

--Viz6) Total Incidents Forecast Indicator for Top states (by year; 2012-2022)
SELECT state, YEAR(declaration_date) AS year, COUNT(DISTINCT disaster_number) AS total_declarations 
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY state, YEAR(declaration_date)
HAVING YEAR(declaration_date) BETWEEN 2012 AND 2022
ORDER BY state ASC, YEAR(declaration_date) DESC;

--Viz7) Pie Chart: 8 most common incident_types in U.S.
SELECT TOP 8 incident_type, COUNT(DISTINCT disaster_number) AS total_disasters
FROM Disasters.dbo.FEMA_DisasterDeclarations
GROUP BY incident_type
ORDER BY total_disasters DESC;

--Viz8) Common 2022 incident_types over previous 5 years (May 2013 - May 2022)
SELECT YEAR(declaration_date) AS YEAR, MONTH(declaration_date) AS month, incident_type, 
	COUNT(DISTINCT disaster_number) AS total_declarations
FROM Disasters.dbo.FEMA_DisasterDeclarations
WHERE declaration_date > '2012-05-01'
GROUP BY YEAR(declaration_date), MONTH(declaration_date), incident_type
ORDER BY YEAR(declaration_date) ASC, MONTH(declaration_date) ASC 
