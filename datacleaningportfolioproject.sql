-- Data Cleaning using SQL Queries 
-- Done by Maya K 


-- Selecting all parameters from the table 


SELECT *
FROM PortFolioProject.dbo.NashvilleHousing

--- Standardize data format -- SaleDate


SELECT SaleDateConverted , CONVERT(date,SaleDate)
FROM PortFolioProject.dbo.NashvilleHousing

ALTER TABLE PortFolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortFolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--- Populate Property Address Column

--- Write query to find where property address is null

SELECT *
FROM PortFolioProject.dbo.NashvilleHousing
---WHERE PropertyAddress is Null
order by ParcelID

-- oberseved that for duplicating parcelid there is occurence of same Property Address
-- If the parcel id is same and one of property address is null then we can populate the latter with the first property address.
-- self join with the same table
-- using isnull and updating property address

SELECT a.ParcelID , a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM PortFolioProject.dbo.NashvilleHousing a
JOIN PortFolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM PortFolioProject.dbo.NashvilleHousing a
JOIN PortFolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Split Property address into two columns 
-- comma as delimiter
-- using substring and charindex 

SELECT PropertyAddress,
SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as CITY
FROM PortFolioProject.dbo.NashvilleHousing

-- updating the table with the values

ALTER Table PortFolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER Table PortFolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortFolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))


--- Split Owner Address into 3 Columns 
-- using parsename and replace --- much easier than the substring and charindex\


SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress , ',','.'),3),
PARSENAME(REPLACE(OwnerAddress , ',','.'),2),
PARSENAME(REPLACE(OwnerAddress , ',','.'),1)
FROM PortFolioProject.dbo.NashvilleHousing


-- updating the table with the values

ALTER Table PortFolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

ALTER Table PortFolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

ALTER Table PortFolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)


UPDATE PortFolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',','.'),1)



--- Convert values into same format in " Sold As Vacant " Field 


SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortFolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
order by 2


-- Better to change "Y" to "Yes" and "N" to "No"

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortFolioProject.dbo.NashvilleHousing

UPDATE PortFolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--- Remove duplicates


-- We are assuming that uniqueid is not perfectly unique and there exists chances of multiple land deals 

-- Using ROWNUM  and partitionby 


WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)

SELECT * 
FROM RowNumCTE
where row_num >1


--- DELETE Unused columns 

SELECT *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress , OwnerAddress , TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


--- END 