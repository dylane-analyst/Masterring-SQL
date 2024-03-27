

-- VIEW ALL DATE IN THE TABLE Dashvillehousimg

SELECT * FROM Dashvillehousing

-- standazise date type
SELECT SaleDate
FROM Dashvillehousing

-- change saledate to date type

alter table Dashvillehousing alter column SaleDate  date
/* or
 cast (saledate as date) or convert(date , saledate)
 update Dashvillehousing set 
 saledate=cast (saledate as date)*/

 -- populate propreti address
 
-- self join to select all property who has not  address and have same parcelID and different unique id
SELECT a.[UniqueID ] , a.PropertyAddress,b.ParcelID,b.PropertyAddress , isnull( a.PropertyAddress,b.PropertyAddress) new
 FROM Dashvillehousing a
 join
  Dashvillehousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- filling null address with address corresponding  

update a set a.PropertyAddress =isnull( a.PropertyAddress,b.PropertyAddress)
from
 Dashvillehousing a
 join
  Dashvillehousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



-- breakind down the property address in  (address ,city )

 select  SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) address,
         SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) city
from     Dashvillehousing
 
 alter table  Dashvillehousing  add   splitproperty_address varchar(30)
 alter table  Dashvillehousing  add   splitproperty_city varchar(30)

 SELECT * FROM Dashvillehousing
 update Dashvillehousing 
 set splitproperty_address= cast(SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as nvarchar)


 update Dashvillehousing 
 set splitproperty_city = cast( SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))as nvarchar)
 
      
-- breaking down the ownerAddress in (address ,city , state)

select * from Dashvillehousing
select
        PARSENAME(replace(OwnerAddress,',','.'),3) as owner_address,
        PARSENAME(replace(OwnerAddress,',','.'),2) as owner_city,
         PARSENAME(replace(OwnerAddress,',','.'),1) as owner_state
from Dashvillehousing

alter table  Dashvillehousing  add   owner_address varchar(30)
 alter table  Dashvillehousing  add   ownercity varchar(30)
 exec sp_rename 'Dashvillehousing.ownercity' , 'owner_city' ,'column'
 alter table  Dashvillehousing  add   owner_state varchar(30)
 
 update Dashvillehousing 
 set owner_address=PARSENAME(replace(OwnerAddress,',','.'),3) 

 
 update Dashvillehousing 
 set owner_city=PARSENAME(replace(OwnerAddress,',','.'),2)
 
 update Dashvillehousing 
 set owner_state=PARSENAME(replace(OwnerAddress,',','.'),1) 



 -- chande No and Yes to n and y in soldAsvacant column
 select 
 case 
    when SoldAsVacant='N'      then   replace(SoldAsVacant,'N','No') 
	when SoldAsVacant='Y'      then   replace(SoldAsVacant,'Y','yes') 
	else    'N'
end
 from Dashvillehousing

 update Dashvillehousing 
 set SoldAsVacant=case 
    when SoldAsVacant='No'      then   replace(SoldAsVacant,'N','No') 
	when SoldAsVacant='Yes'      then   replace(SoldAsVacant,'Y','yes') 
	else 'N'
end
-- remove duplicate

select * from Dashvillehousing

with duplicate  as (select *,
ROW_NUMBER() over(partition by parcelID,property_Address,saledate,saleprice order by uniqueID) as n_w
from Dashvillehousing)
select *  from duplicate
where n_w>=2

-- delete unuseble row
select * from Dashvillehousing

alter table   Dashvillehousing drop column taxDistrict, ownerAddress,propertyaddress 
