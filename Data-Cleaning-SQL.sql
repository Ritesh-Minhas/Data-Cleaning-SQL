-- Selecting the Database
USE PortfolioProject;

-- Browsing the Data
SELECT * FROM NashvilleHousing;

-------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);


SELECT SaleDateConverted 
FROM NashvilleHousing;

--------------------------------------------------------------

-- Populate PropertyAddress Data

SELECT * 
FROM NashvilleHousing
ORDER BY ParcelID

-- SELF JOIN ON Same ParcelID to fill the Property Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- UPDATING the data for NULL PropertyAddress

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------

-- Splitting PropertyAddress into Individual Column (Address, City)

-- Selecting the Substring for splitting by Delimiter

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing;

-- Adding Columns to Insert the Splitted Address

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Splitting OwnerAddress into Individual Column (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
FROM NashvilleHousing;

-- Adding Columns to Insert the Splitted Address

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-------------------------------------------------------------------------

-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant Column

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-- Checking the Updated Values

SELECT SoldAsVacant, COUNT(SoldAsVacant) AS CountOfVacant
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


-----------------------------------------------------------------------

-- Removing Duplicates 

-- Using CTE

WITH CTE_ROWNUM AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
				) AS row_num

FROM NashvilleHousing
)

SELECT *
FROM CTE_ROWNUM
WHERE row_num > 1


-----------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;


-----------------------------------------------------------------------------------------
-- The Cleaned Dataset

SELECT * FROM NashvilleHousing;