Select *
From PortfolioProject.dbo.HousingData

-- Modifying Sale Date

Select SaleDate
From PortfolioProject.dbo.HousingData


ALTER TABLE PortfolioProject.dbo.HousingData
ALTER COLUMN SaleDate Date;


-- Property Address Missing Value Imputation

Select *
From PortfolioProject.dbo.HousingData
Where PropertyAddress is null
Order By ParcelID


Select o.ParcelID, o.PropertyAddress, t.ParcelID, t.PropertyAddress, ISNULL(o.PropertyAddress, t.PropertyAddress)
From PortfolioProject.dbo.HousingData o
JOIN PortfolioProject.dbo.HousingData t
	On o.ParcelID = t.ParcelID
	AND o.[UniqueID ] <> t.[UniqueID ]
Where o.PropertyAddress is null;

Update o
SET PropertyAddress = ISNULL(o.PropertyAddress, t.PropertyAddress)
From PortfolioProject.dbo.HousingData o
JOIN PortfolioProject.dbo.HousingData t
	On o.ParcelID = t.ParcelID
	AND o.[UniqueID ] <> t.[UniqueID ]
Where o.PropertyAddress is null;



-- Splitting PropertyAddress into different fields

Select PropertyAddress
From PortfolioProject.dbo.HousingData

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
Add PropertySplitStreet Nvarchar(255);

UPDATE HousingData
Set PropertySplitStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

UPDATE HousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.HousingData



-- Alternate way to Split-up the PropertyAddress Field

Select PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)
, PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
From PortfolioProject.dbo.HousingData

ALTER TABLE HousingData
Add PropertySplitStreet Nvarchar(255);

UPDATE HousingData
Set PropertySplitStreet = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

UPDATE HousingData
Set PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)



-- Splitting PropertyAddress into different fields

Select OwnerAddress
From PortfolioProject.dbo.HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
Add OwnerSplitStreet Nvarchar(255);

UPDATE HousingData
Set OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

UPDATE HousingData
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

UPDATE HousingData
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProject.dbo.HousingData



-- Change the Y's Yes's and N's to No's in the SoldAsVacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.HousingData
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From PortfolioProject.dbo.HousingData

Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *
, ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By 
					ParcelID
					) row_num
From PortfolioProject.dbo.HousingData
--Order By ParcelID
)
DELETE
--Select *
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress



-- Delete Unused Columns

Select *
From PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress