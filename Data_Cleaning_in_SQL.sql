SELECT
	*
FROM PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------
---Standardize Date Format

SELECT 
	SaleDateConverted, CONVERT(Date, SaleDate)
FROM 
	PortfolioProject..NashvilleHousing

ALTER TABLE
	ProjectPortfolio..NashvilleHousing
ADD 
	SaleDateConverted Date;

UPDATE 
	PortfolioProject..NashvilleHousing
SET 
	SaleDateConverted= CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------
--Populate Property Adress NULLS


SELECT 
	*
FROM 
	PortfolioProject..NashvilleHousing
ORDER BY
	ParcelID


SELECT 
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject..NashvilleHousing as a
JOIN
	PortfolioProject..NashvilleHousing as b
	ON a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null
	

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	PortfolioProject..NashvilleHousing as a
JOIN
	PortfolioProject..NashvilleHousing as b
	ON a.ParcelID =b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is null

------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, Sate)

SELECT 
	PropertyAddress
FROM 
	PortfolioProject..NashvilleHousing


SELECT 
	SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Adress,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Adress
FROM 
	PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT
	OwnerAddress
FROM 
	PortfolioProject..NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
	,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM 
	PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


----------------------------------------------------------------------
--Change Y and N to Yes or No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldASVacant)
FROM
	PortfolioProject..NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2


SELECT SoldAsVacant
	,Case
		WHEN SoldAsVacant='Y' Then 'Yes'
		WHEN SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
		END As Fixed
FROM
	PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =Case
		WHEN SoldAsVacant='Y' Then 'Yes'
		WHEN SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
		END 

-----------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				  ORDER BY
					UniqueID
					) row_num
FROM
	PortfolioProject..NashvilleHousing

)
SELECT *
FROM 
	RowNumCTE
WHERE 
	row_num >1

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

