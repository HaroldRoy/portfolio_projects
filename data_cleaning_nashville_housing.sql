/*

Cleaning Data in SQL Queries

*/


----------------------------------------------------------------------------------------------

SELECT *
FROM portfolio_project..nashville_housing;

--Standardize Date Format

SELECT  SaleDate, 
		CONVERT(date, SaleDate)
FROM portfolio_project..nashville_housing;

Update nashville_housing
SET SaleDate = CONVERT(date, SaleDate)

--If it doesn't Update properly

ALTER TABLE nashville_housing
ADD SaleDate2 DATE

Update nashville_housing
SET SaleDate2 = CONVERT(date, SaleDate);

SELECT  SaleDate,
		SaleDate2
FROM portfolio_project..nashville_housing;


----------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM portfolio_project..nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


SELECT  ori.[UniqueID ],
		rep.[UniqueID ],
		ori.ParcelID,
		rep.ParcelID,
		ori.PropertyAddress,
		rep.PropertyAddress,
		ISNULL(ori.PropertyAddress, rep.PropertyAddress)
FROM portfolio_project..nashville_housing AS ori
JOIN portfolio_project..nashville_housing AS rep
	ON ori.ParcelID = rep.ParcelID
	AND ori.[UniqueID ] <> rep.[UniqueID ]
WHERE ori.PropertyAddress IS NULL;

UPDATE ori
SET PropertyAddress = ISNULL(ori.PropertyAddress, rep.PropertyAddress)
FROM portfolio_project..nashville_housing AS ori
JOIN portfolio_project..nashville_housing AS rep
	ON ori.ParcelID = rep.ParcelID
	AND ori.[UniqueID ] <> rep.[UniqueID ]
WHERE ori.PropertyAddress IS NULL;


----------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns(Address, City, State)

SELECT  PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address_clean,
		SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM portfolio_project..nashville_housing;

ALTER TABLE nashville_housing
ADD PropertyAddressClean VARCHAR(255)

Update nashville_housing
SET PropertyAddressClean = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE nashville_housing
ADD PropertyAddressCity VARCHAR(255)

Update nashville_housing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT  PropertyAddress,
		PropertyAddressClean,
		PropertyAddressCity
FROM portfolio_project..nashville_housing;


--Using alternative method with the OwnerAddress

SELECT  OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM portfolio_project..nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerAddressClean VARCHAR(255)

Update nashville_housing
SET OwnerAddressClean = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE nashville_housing
ADD OwnerCity VARCHAR(255)

Update nashville_housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE nashville_housing
ADD OwnerState VARCHAR(255)

Update nashville_housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);


SELECT  OwnerAddress,
		OwnerAddressClean,
		OwnerCity,
		OwnerState
FROM portfolio_project..nashville_housing;


----------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select  Distinct(SoldAsVacant),
		Count(SoldAsVacant)
FROM portfolio_project..nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT  SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldASVacant
			 END
FROM portfolio_project..nashville_housing;

Update nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldASVacant
						END


----------------------------------------------------------------------------------------------

--Remove Duplicates

WITH row_num_cte AS(
SELECT  *,
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
			ORDER BY UniqueID
) AS row_num							
FROM portfolio_project..nashville_housing
--ORDER BY ParcelID
)
DELETE
FROM row_num_cte
WHERE row_num > 1
--ORDER BY PropertyAddress;


----------------------------------------------------------------------------------------------

--Delete Unused Colulmns

SELECT *
FROM portfolio_project..nashville_housing

ALTER TABLE portfolio_project..nashville_housing
DROP COLUMN OwnerAddress,
			TaxDistric,
			PropertyAddress,
			SaleDate;