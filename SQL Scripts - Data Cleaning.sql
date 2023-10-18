--Dataset (initial view)

Select *
From [Project 1 - Nashville Housing Data].[dbo].[NashvilleData]


--Populate Property Address data (Note that Parcel ID and Property Address always match) and using "Parcel ID" to search for NULL Addresses in the same dataset

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Project 1 - Nashville Housing Data]..[NashvilleData] a
Join [Project 1 - Nashville Housing Data]..[NashvilleData] b
	On a.ParcelID = b.ParcelID 
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Project 1 - Nashville Housing Data]..[NashvilleData] a
Join [Project 1 - Nashville Housing Data]..[NashvilleData] b
	On a.ParcelID = b.ParcelID 
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Select *
From [Project 1 - Nashville Housing Data]..[NashvilleData]
where PropertyAddress is null


--Breaking out "Property Address" into "Address" and "City" using SUBSTRING function and adding them as new columns

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From [Project 1 - Nashville Housing Data]..[NashvilleData]

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ADD PropertyAddress_split varchar(100)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET PropertyAddress_split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ADD PropertyCity_split varchar(100)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET PropertyCity_split = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select PropertyAddress, PropertyAddress_split, PropertyCity_split
From [Project 1 - Nashville Housing Data]..[NashvilleData]


--Breaking out "Owner Address" into "Address", "City", and "State" using PARSENAME function and adding them as new columns

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3) as OwnerAddress_split,
PARSENAME(REPLACE(OwnerAddress,',', '.'),2) as OwnerCity_split,
PARSENAME(REPLACE(OwnerAddress,',', '.'),1) as OwnerState_split
From [Project 1 - Nashville Housing Data]..[NashvilleData]

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ADD OwnerAddress_split varchar(100)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET OwnerAddress_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ADD OwnerCity_split varchar(100)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET OwnerCity_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ADD OwnerState_split varchar(100)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET OwnerState_split = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

Select OwnerAddress, OwnerAddress_split, OwnerCity_split, OwnerState_split
From [Project 1 - Nashville Housing Data]..[NashvilleData]


--Change the binary legend 0-1 from column "Sold as Vacant" to its respective text description "No" (0) and "Yes" (1)

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
ALTER COLUMN SoldAsVacant varchar(10)

UPDATE [Project 1 - Nashville Housing Data]..[NashvilleData]
SET SoldAsVacant= 
CASE 
	WHEN SoldAsVacant=0 THEN 'No' 
	ELSE 'Yes' 
	END
From [Project 1 - Nashville Housing Data]..[NashvilleData]

Select SoldAsVacant, COUNT(SoldAsVacant) as Count
From [Project 1 - Nashville Housing Data]..[NashvilleData]
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
From [Project 1 - Nashville Housing Data]..[NashvilleData])

Select *
From CTE_RowNum
WHERE Row_num > 1


--Deleting Unused Address Columns

ALTER TABLE [Project 1 - Nashville Housing Data]..[NashvilleData]
DROP COLUMN PropertyAddress,OwnerAddress

Select *
From [Project 1 - Nashville Housing Data]..[NashvilleData]


--Done! Dataset is ready for exporting and analysis!
