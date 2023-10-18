--Dataset (initial view)

Select *
From NashvilleData


--Populate Property Address data (Note that Parcel ID and Property Address always match) 
--and using "Parcel ID" to search for NULL Addresses in the same dataset

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleData a
Join NashvilleData b
	On a.ParcelID = b.ParcelID 
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleData a
Join NashvilleData b
	On a.ParcelID = b.ParcelID 
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Select *
From NashvilleData
where PropertyAddress is null


--Breaking out Property Address into Address, City using "SUBSTRING" and adding them as new columns

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashvilleData

ALTER TABLE NashvilleData
ADD PropertyAddress_split varchar(100)

UPDATE NashvilleData
SET PropertyAddress_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleData
ADD PropertyCity_split varchar(100)

UPDATE NashvilleData
SET PropertyCity_split = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select PropertyAddress, PropertyAddress_split, PropertyCity_split
From NashvilleData


--Breaking out Owner Address into Address, City, State using PARSENAME and adding them as new columns

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3) as OwnerAddress_split,
PARSENAME(REPLACE(OwnerAddress,',', '.'),2) as OwnerCity_split,
PARSENAME(REPLACE(OwnerAddress,',', '.'),1) as OwnerState_split
From NashvilleData

ALTER TABLE NashvilleData
ADD OwnerAddress_split varchar(100)

UPDATE NashvilleData
SET OwnerAddress_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleData
ADD OwnerCity_split varchar(100)

UPDATE NashvilleData
SET OwnerCity_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleData
ADD OwnerState_split varchar(100)

UPDATE NashvilleData
SET OwnerState_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

Select OwnerAddress, OwnerAddress_split, OwnerCity_split, OwnerState_split
From NashvilleData


--Change the binary legend 0-1 from column "Sold as Vacant" to the respective text description "No" (0) and "Yes" (1)

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant=0 THEN 'No'
	ELSE 'Yes'
	END
From NashvilleData

ALTER TABLE NashvilleData
ALTER COLUMN SoldAsVacant varchar(10)
UPDATE NashvilleData
SET SoldAsVacant= CASE WHEN SoldAsVacant=0 THEN 'No' ELSE 'Yes' END
From NashvilleData

Select SoldAsVacant, COUNT(SoldAsVacant) as Count
From NashvilleData
Group by SoldAsVacant
Order by Count


--Searching for duplicates

With CTE_RowNum as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference,
				 UniqueID 
				 Order by UniqueID) as Row_num
From NashvilleData)

Select *
From CTE_RowNum
WHERE Row_num > 1


--Deleting Unused Address Columns

ALTER TABLE NashvilleData
DROP COLUMN PropertyAddress,OwnerAddress

Select *
From NashvilleData


--Dataset is ready for exporting and analysis!!
