--- Here I will change the sale date format to make the sales data data consistent across the column

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = Convert(Date,SaleDate)

----------------------------------------------------------------------------------

--- Populating the property address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


------------------------------------------------------------------------------------------------

---Separating the address into individual columns (address, city, state)

SELECT PropertyAddress
FROM NashvilleHousing
ORDER BY ParcelID

--- The following separates the street address from the city in two different columns using substrings

SELECT
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,	Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarChar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity NVarChar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT OwnerAddress
FROM NashvilleHousing
WHERE OwnerAddress IS Not Null

--- This separates the owner address into three separate columns: Address, City, and State; by using the PARSENAME command to separate the string

--- Since the PARSENAME function only separates periods in the string, we first need to convert the commas to periods in the string

SELECT
ParseName(Replace(OwnerAddress, ',', '.') ,3)
,ParseName(Replace(OwnerAddress, ',', '.') ,2)
,ParseName(Replace(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing
WHERE OwnerAddress is not null

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarChar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVarChar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState NVarChar(255)

UPDATE NashVilleHousing
SET OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.') ,1)

--- Next, we must change the Y and N to Yes and No in the SoldAsVacant column, since the data is inconsistent in this column

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant = 'N' THEN 'No'
	     WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	     WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

--- Next, we will remove duplicate rows
--- In order to do this, we must first identify the duplicate rows, then delete those rows after they are identified

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--- Lastly, we will delete unused columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

