/*
	Cleaning Data in SQL Queries
*/


SELECT *
FROM portfolio_project.dbo.nashville_housing


--1.
--Standardize or Changing Date Format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM portfolio_project..nashville_housing

UPDATE portfolio_project..nashville_housing                  --tried to update "nashville_housing" table using this query but didn't work
SET SaleDate = CONVERT(date, SaleDate)    --so, tried another method by creating new column "SaleDateConverted"


ALTER TABLE nashville_housing
ADD SaleDateConverted date;

UPDATE portfolio_project..nashville_housing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM portfolio_project..nashville_housing



--2.
--Populate Property Address Data
SELECT*
FROM portfolio_project..nashville_housing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..nashville_housing a
JOIN portfolio_project..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project..nashville_housing a
JOIN portfolio_project..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL



--3.
--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM portfolio_project..nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS city
FROM portfolio_project..nashville_housing

ALTER TABLE portfolio_project..nashville_housing
ADD PropertyAddress_split nvarchar(255);

UPDATE portfolio_project..nashville_housing
SET PropertyAddress_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE portfolio_project..nashville_housing
ADD PropertyCity_split nvarchar(255);

UPDATE portfolio_project..nashville_housing
SET PropertyCity_split = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM portfolio_project.dbo.nashville_housing




SELECT OwnerAddress
FROM portfolio_project.dbo.nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio_project.dbo.nashville_housing

ALTER TABLE portfolio_project..nashville_housing
ADD OwnerAddress_split nvarchar(255);

UPDATE portfolio_project..nashville_housing
SET OwnerAddress_split = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE portfolio_project..nashville_housing
ADD OwnerCity_split nvarchar(255);

UPDATE portfolio_project..nashville_housing
SET OwnerCity_split = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE portfolio_project..nashville_housing
ADD OwnerState_split nvarchar(255);

UPDATE portfolio_project..nashville_housing
SET OwnerState_split = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




--4.
--Change Y and  N to Yes and No in "Sold as Vacant" field   
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)    --from here, i concluded that, there are 52 count of 'Y'
FROM portfolio_project.dbo.nashville_housing                                                 --399 count of 'N'
GROUP BY SoldAsVacant                                                                        --4623 count of 'Yes' and
ORDER BY 2                                                                                   --51403 count of 'No'.


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM portfolio_project..nashville_housing

UPDATE portfolio_project.dbo.nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'   --so, after updating it became 4675 count of 'Yes' ans 51802 count of 'No'.
		                WHEN SoldAsVacant = 'N' THEN 'No'
		                ELSE SoldAsVacant
	               END




--5.
--Remove Duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
						 ORDER BY UniqueID
						 ) row_num
FROM portfolio_project.dbo.nashville_housing
--ORDER BY ParcelID
)
--SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



--6.
--Delete Unused Columns
SELECT *
FROM portfolio_project..nashville_housing

ALTER TABLE portfolio_project..nashville_housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, address, city
