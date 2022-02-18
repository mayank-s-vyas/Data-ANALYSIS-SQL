-- DATA CLEANING OF Nashville Housing DATA

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------

--Standardize the SaleDate

Select SaleDate, CONVERT(DATE, SaleDate)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD SaleDateConv DATE

UPDATE NashvilleHousing
SET SaleDateConv = CONVERT(DATE, SaleDate)



Select SaleDateConv
From PortfolioProject.dbo.NashvilleHousing



------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

--check the null in property address and check if it's related to ather column, as property address shouldn't be null

Select *
From PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Parcelid and property address have similarity, for each property they are same
SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL

--Find out if we have more parcelid having the address, so that we can populate them using those parcelid

SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--create a column for filling null values of propertyaddress null values
SELECT a.[UniqueID ],a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Update table with filling all null values

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS State
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--Owner Address Splitting

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------------

--CHANGE Y and N to Yes and No inn "SoldASVacant"

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
						END

						--
-------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

WITH RowNumCTE AS(

SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID
									,PropertyAddress
									,SaleDate
									,SalePrice
									,LegalReference
									,OwnerName
									,OwnerAddress
									ORDER BY 
										UniqueID) as row_num

FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID


WITH RowNumCTE AS(

SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID
									,PropertyAddress
									,SaleDate
									,SalePrice
									,LegalReference
									,OwnerName
									,OwnerAddress
									ORDER BY 
										UniqueID) as row_num

FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID


--------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict




