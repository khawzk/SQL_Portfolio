SELECT
	*
FROM
	PortfolioProject.dbo.NashVilleHousing

--STANDARDIZE DATE FORMAT

SELECT
	SALEDATE,CONVERT(DATE,SALEDATE)
FROM
	PortfolioProject.dbo.NashVilleHousing

UPDATE
	NashVilleHousing
SET SALEDATE = CONVERT(DATE,SALEDATE)

ALTER TABLE NashVilleHousing
ADD ConvertedSaleDate Date;

UPDATE
	NashVilleHousing
SET ConvertedSaleDate = CONVERT(Date,SALEDATE)

--Populate Property Address Data


SELECT
	a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashVilleHousing a
JOIN
	PortfolioProject.dbo.NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashVilleHousing a
JOIN
	PortfolioProject.dbo.NashVilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out Address into different field(Address,City,States)
SELECT PropertyAddress
FROM
	PortfolioProject.dbo.NashVilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address 
FROM
	PortfolioProject.dbo.NashVilleHousing


ALTER TABLE NashVilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE
	NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE
	NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	PortfolioProject..NashVilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
ALTER TABLE NashVilleHousing
ADD OwnerSplitCity NVARCHAR(255);
ALTER TABLE NashVilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..NashVilleHousing

--CHANGE Y AND N TO YES AND NO

SELECT DISTINCT(SoldAsVacant),cOUNT(SoldAsVacant)
FROM PortfolioProject..NashVilleHousing
Group by SoldAsVacant
Order by 2
	
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SOLDASVACANT
	END
FROM PortfolioProject..NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SOLDASVACANT
	END

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,LegalReference
	ORDER BY
        UniqueID)row_num
FROM PortfolioProject..NashVilleHousing
)

DELETE
FROM RowNumCTE
WHERE ROW_NUM >1


SELECT *
FROM PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN SaleDate
