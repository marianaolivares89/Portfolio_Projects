/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM [Portfolio Project].dbo.Nashville_Housing


-- Standardize Date Format

SELECT SaleDate_2, CONVERT(date, SaleDate)
FROM [Portfolio Project].dbo.Nashville_Housing

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD SaleDate_2 Date;

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET SaleDate_2 = CONVERT(date, SaleDate)



--Populate Property Address data

SELECT *
FROM [Portfolio Project].dbo.Nashville_Housing
-- WHERE PropertyAddress is Null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM [Portfolio Project].dbo.Nashville_Housing AS a
JOIN [Portfolio Project].dbo.Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
--WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.Nashville_Housing AS a
JOIN [Portfolio Project].dbo.Nashville_Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-- Breaking out Address into individual Columns (Adress, City, State)

-- PropertyAddress

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City 
FROM [Portfolio Project].dbo.Nashville_Housing

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD Property_Address Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD Property_City Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [Portfolio Project].dbo.Nashville_Housing


-- OwnerAddress

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM [Portfolio Project].dbo.Nashville_Housing

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD Owner_Address Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD Owner_City Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
ADD Owner_State Nvarchar(255);

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM [Portfolio Project].dbo.Nashville_Housing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project].dbo.Nashville_Housing

UPDATE [Portfolio Project].dbo.Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


-- Remove Duplicates

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) AS row_count
FROM [Portfolio Project].dbo.Nashville_Housing

-- CTE to delete duplicates

WITH Row_num_CTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) AS row_count
FROM [Portfolio Project].dbo.Nashville_Housing
)
DELETE
FROM Row_num_CTE
WHERE row_count > 1


-- Delete Unused Columns

SELECT *
FROM [Portfolio Project].dbo.Nashville_Housing

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.Nashville_Housing
DROP COLUMN SaleDate