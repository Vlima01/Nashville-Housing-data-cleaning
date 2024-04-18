SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Data Cleaning].[dbo].[NashvilleHousing]

  --Cleaning data in SQL

    SELECT *
    FROM [Data Cleaning].[dbo].[NashvilleHousing]

  --Standardize date format

    SELECT SaleDateConverted, CONVERT(Date,SaleDate)
    FROM [Data Cleaning].[dbo].[NashvilleHousing]

	UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)

	----Use this if table did not update

	ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date;

	UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(date,SaleDate)


  --Populate property address 

    SELECT PropertyAddress
    FROM [Data Cleaning].[dbo].[NashvilleHousing]
	WHERE PropertyAddress is null

	SELECT *
    FROM [Data Cleaning].[dbo].[NashvilleHousing]
	WHERE PropertyAddress is null

	SELECT *
    FROM [Data Cleaning].[dbo].[NashvilleHousing]
	--WHERE PropertyAddress is null
	ORDER BY ParcelID

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
    FROM [Data Cleaning].[dbo].[NashvilleHousing] A
	JOIN [Data Cleaning].[dbo].[NashvilleHousing] B
	  ON a.ParcelID = b.ParcelID
	  AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress is null

	
	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
    FROM [Data Cleaning].[dbo].[NashvilleHousing] A
	JOIN [Data Cleaning].[dbo].[NashvilleHousing] B
	  ON a.ParcelID = b.ParcelID
	  AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress is null

	UPDATE a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM [Data Cleaning].[dbo].[NashvilleHousing] A
	JOIN [Data Cleaning].[dbo].[NashvilleHousing] B
	  ON a.ParcelID = b.ParcelID
	  AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress is null

  --Breaking out address into individual colums (address, city, state)

    SELECT PropertyAddress
    FROM [Data Cleaning].[dbo].[NashvilleHousing]
	
	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	---Remove Comma

	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	---Creating a column without the comma but with the city

	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255);

	UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

	ALTER TABLE NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

	UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

	SELECT *
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	SELECT OwnerAddress 
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	---Parsename only works with . but if we have a , then use this

	SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	---Rename Columns
	 
	ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress Nvarchar(255)

	UPDATE NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

	ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity Nvarchar(255);

	UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
	
	ALTER TABLE NashvilleHousing
	ADD OwnerSplitState Nvarchar(255);

	UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

	SELECT *
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

  --Change Y and and N to Yes and No in 'sold as vacant'

    SELECT DISTINCT(SoldAsVacant)
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

    SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM [Data Cleaning].[dbo].[NashvilleHousing]
	GROUP BY SoldAsVacant
	ORDER BY 2

	SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		    END
	FROM [Data Cleaning].[dbo].[NashvilleHousing]

	UPDATE NashvilleHousing 
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		    END

    SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM [Data Cleaning].[dbo].[NashvilleHousing]
	GROUP BY SoldAsVacant
	ORDER BY 2


  --Remove duplicates
  ---Finding duplicates

  WITH RowNumCTE AS(
  SELECT *,
     ROW_NUMBER () OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				  UniqueID
				  ) row_num

	FROM [Data Cleaning].[dbo].[NashvilleHousing]
	)
	SELECT *
	FROM RowNumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress

	---Removing process

	 WITH RowNumCTE AS(
  SELECT *,
     ROW_NUMBER () OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				  UniqueID
				  ) row_num

	FROM [Data Cleaning].[dbo].[NashvilleHousing]
	)
	DELETE
	FROM RowNumCTE
	WHERE row_num > 1
	--ORDER BY PropertyAddress



  --Delete unused columns

  SELECT *
  FROM [Data Cleaning].[dbo].[NashvilleHousing]

  ALTER TABLE [Data Cleaning].[dbo].[NashvilleHousing]
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER TABLE [Data Cleaning].[dbo].[NashvilleHousing]
  DROP COLUMN SaleDate