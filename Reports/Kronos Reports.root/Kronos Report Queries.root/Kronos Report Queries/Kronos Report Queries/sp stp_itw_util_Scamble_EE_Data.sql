SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_util_Scamble_EE_Data]

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/25/2010
	Parameters: None
	Description: Scambles certain employee data for privacy reasons.  
	****Should only be used on the Kronos test or reporting server****
	Example: exec dbo.stp_itw_util_Scamble_EE_Data
	Revisions: MF 1/25/2010 1.0 Created
   =============================================*/
	set nocount on;

	--variables for final address values generated from tables
	declare @countryname varchar(2);
	declare @statename varchar(3);
	declare @cityname varchar(50);
	declare @streetname varchar(50);
	declare @streettypename varchar(5);
	
	--variables for final address values generated randomly
	declare @postalcode varchar(7);
	declare @streetnumber int;
	
	--variables to hold the counts of rows in the table variables
	declare @countcountry int;
	declare @countstate int;
	declare @countcity int;
	declare @countstreet int;
	declare @countstreettype int;
	
	--variables used to generate the postal codes
	declare @alphabet char(36);
	declare @char1 char(1);
	declare @char2 char(1);
	declare @char3 char(1);
	declare @char4 char(1);
	declare @char5 char(1);
	declare @char6 char(1);
	
	--variables for the cursor
	declare @PERSONID int,
      @STREETADDRESSTXT varchar(100),
      @CITYNM varchar(25),
      @STATENM varchar(25),
      @POSTALCD varchar(25),
      @COUNTRYNM varchar(25);
      
    --variables for the birthdates
    declare @minbirthdate datetime;
    declare @maxbirthdate datetime;
    declare @countdays int;
    declare @birthdate datetime;
	
	
	--Create tables to hold possible data
	--Postal address
	/*The postal address will be made of a number, a street name, and "type" or road (street, aveneue, etc.).
	There will also be a country, city, state/province and postal code.
	To make the data somewhat realistic, the province or state, city and postal or zip will be decided 
	by the country.
	Tables of candidate street names, countries, provices/states and cities will be created.  The exact value
	to be used from these tables will be determined randomly.*/
	declare @Country table(
	id int IDENTITY(1,1) NOT NULL,
	countryname varchar(2) not null);
	
	declare @provstate table(
	id int NOT NULL,
	country varchar(2) not null,
	provstatename varchar(3) not null);
	
	declare @city table(
	id int not null,
	provstate varchar(3) not null,
	city varchar(50) not null);
	
	declare @street table(
	id int identity(1,1) not null,
	street varchar(50) not null);
	
	declare @streettype table(
	id int identity(1,1) not null,
	streettype varchar(5) not null);
	
	declare  cAddress cursor local fast_forward for
	SELECT [PERSONID]
      ,[STREETADDRESSTXT]
      ,[CITYNM]
      ,[STATENM]
      ,[POSTALCD]
      ,[COUNTRYNM]
     from dbo.postaladdress;
     
	declare  cBirthdate cursor local fast_forward for
	SELECT [PERSONID]
	FROM dbo.[PERSON]
	where birthdtm is not null;
	
	--Load countries
	insert into @country
	(countryname)
	select 'CA' union select 'US' union select 'AU' union select 'GB';
	
	--Load provinces/states
	insert into @provstate
	(id, country, provstatename)
	values
	(10, 'CA', 'AB')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(1,'CA', 'BC')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(2,'CA', 'MB')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(3,'CA', 'NB')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(4,'CA', 'NL')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(5,'CA', 'NS')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(6,'CA', 'ON')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(7,'CA', 'PE')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(8,'CA', 'QC')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(9,'CA', 'SK')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(4,'AU', 'NSW')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(1, 'AU', 'WAA')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(2,'AU', 'NTA')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(3,'AU', 'QLD')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(3,'US', 'WA')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(1,'US', 'CA')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(2,'US', 'OR')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(2,'GB', 'LON')
	
	insert into @provstate
	(id, country, provstatename)
	values
	(1,'GB', 'OX')
	
	--Load cities
	insert into @city
	(id, provstate, city)
	values
	(1,'BC', 'Vancouver')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'BC', 'Kelona')
	
	insert into @city
	(id, provstate, city)
	values
	(3,'BC', 'Whistler')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'AB', 'Calgary')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'AB', 'Edmonton')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'SK', 'Saskatoon')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'SK', 'Regina')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'MB', 'Winnepeg')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'ON', 'Toronto')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'ON', 'Kingston')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'QC', 'Quebec')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'QC', 'Montreal')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'NB', 'Frederickton')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'NL', 'St. John''s')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'NS', 'Halifax')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'PE', 'Charlottetown')
	
	insert into @city
	(id, provstate, city)
	values
	(2,'MB', 'Churchill')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'NSW', 'Sydney')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'QLD', 'Cairnes')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'NTA', 'Darwin')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'WAA', 'Perth')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'WA', 'Springfield')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'CA', 'Springfield')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'OR', 'Springfield')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'LON', 'London')
	
	insert into @city
	(id, provstate, city)
	values
	(1,'OX', 'Oxford')
	
	--Load Streets
	insert into @street
	(street)
	values
	('Main')
	
	insert into @street
	(street)
	values
	('1st')
	
	insert into @street
	(street)
	values
	('Broadway')
	
	insert into @street
	(street)
	values
	('Oak')
	
	insert into @street
	(street)
	values
	('Fraser')
	
	--Load street types
	insert into @streettype
	(streettype)
	values
	('St.')
	
	insert into @streettype
	(streettype)
	values
	('Ave.')
	
	insert into @streettype
	(streettype)
	values
	('Dr.')
	
	insert into @streettype
	(streettype)
	values
	('Rd.')
	
	insert into @streettype
	(streettype)
	values
	('Cres.')
	
	--Figure out the total number of records in tables.  This is used to determin the maximum id for the random number generator.
	select @countcountry = count(*) from @country;
	select @countstreet = count(*) from @street;
	select @countstreettype = count(*) from @streettype;
	
	--Used for postal codes
	set @alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
	
	--Loop through every record in the table
	open caddress;
	
	fetch next from cAddress into
	@PERSONID, @STREETADDRESSTXT, @CITYNM, @STATENM, @POSTALCD, @COUNTRYNM;
	
	while @@fetch_status = 0
	begin
	
		--Create address
		set @postalcode = '';
		
		--Country
		select @countryname = countryname
		from @country
		where id = floor(rand() * @countcountry) + 1;
		
		--State 
		select @countstate = count(*)
		from @provstate
		where country = @countryname;
		
		select @statename = provstatename
		from @provstate
		where country = @countryname
		and id = floor(rand() * @countstate) + 1;
		
		--City
		select @countcity = count(*)
		from @city
		where provstate = @statename;
		
		select @cityname = city
		from @city
		where provstate = @statename
		and id = floor(rand() * @countcity) + 1;
		
		--Street
		select @streetname = street
		from @street
		where id = floor(rand() * @countstreet) + 1;
		
		--Street type
		select @streettypename = streettype
		from @streettype
		where id = floor(rand() * @countstreettype) + 1;
		
		--Street number
		set @streetnumber = floor(rand() * 9998) + 1;
		
		--Postal code
		if @countryname = 'CA'
		begin
			--Canadian postal codes have the format A1A 1A1
			set @char1 = substring(@alphabet, cast(floor(rand() * 26) + 1 as int), 1);
			set @char2 = cast(floor(rand() * 10) as char(1));
			set @char3 = substring(@alphabet, cast(floor(rand() * 26) + 1 as int), 1);
			set @char4 = cast(floor(rand() * 10) as char(1));
			set @char5 = substring(@alphabet, cast(floor(rand() * 26) + 1 as int), 1);
			set @char6 = cast(floor(rand() * 10) as char(1));
			
			set @postalcode = @char1 + @char2 + @char3 + ' ' + @char4 + @char5 + @char6;
		end;
		else
		begin
			if @countryname = 'GB'
			begin
				/*Not quite sure of the GB format, but going with any alpha for the first
				character and then any letter or number for the remaining 5*/
				set @char1 = substring(@alphabet, cast(floor(rand() * 26 + 1) as int), 1);
				set @char2 = substring(@alphabet, cast(floor(rand() * 36 + 1) as int), 1);
				set @char3 = substring(@alphabet, cast(floor(rand() * 36 + 1) as int), 1);
				set @char4 = substring(@alphabet, cast(floor(rand() * 36 + 1) as int), 1);
				set @char5 = substring(@alphabet, cast(floor(rand() * 36 + 1) as int), 1);
				set @char6 = substring(@alphabet, cast(floor(rand() * 36 + 1) as int), 1);
				
				set @postalcode = @char1 + @char2 + @char3 + ' ' + @char4 + @char5 + @char6;
			
			end;
			else
			begin
			
				if @countryname = 'US'
				begin
					--Starting at 90000 for the US because I've only put in Western states
					set @postalcode = floor(rand() * 9998) + 90000;
				end;
				else
				begin
					--Austrailia seems to have 4 digit codes.  This will do for anyone else as well.
					set @postalcode = floor(rand() * 9998) + 1;
				end;
			end;
		end;
		
		--print cast(@streetnumber as varchar(5)) + ' ' + @streetname + ' ' + @streettypename + ', ' + @cityname + ', ' + @statename + ', ' + @countryname + ', ' + @postalcode;
		
		UPDATE [TKCSDB].[dbo].[POSTALADDRESS]
		SET [STREETADDRESSTXT] = cast(@streetnumber as varchar(5)) + ' ' + @streetname + ' ' + @streettypename
		  ,[CITYNM] = @cityname
		  ,[STATENM] = @statename
		  ,[POSTALCD] = @postalcode
		  ,[COUNTRYNM] = @countryname
		  ,[UPDATEDTM] = getdate()
		WHERE personid = @PERSONID;
		
		fetch next from cAddress into
		@PERSONID, @STREETADDRESSTXT, @CITYNM, @STATENM, @POSTALCD, @COUNTRYNM;
	
	end;
	
	
	--Birth Date
	/*
	We don't want anyone younger than 20 and older than 60.  Use those to figure out the
	earliest and latest birth dates and then the number of days in between and use that with
	the random number generator to calculate a birth date.
	*/
	set @minbirthdate = cast(cast(month(getdate()) as varchar(2)) + '/' + cast(day(getdate()) as varchar(2)) + '/' + cast(year(getdate()) - 60 as varchar(4)) as datetime);
	set @maxbirthdate = dateadd(yyyy, -20, getdate());
	
	set @countdays = datediff(d, @minbirthdate, @maxbirthdate);
	
	open cBirthdate;
	
	fetch next from cBirthdate into @personid;
	
	while @@fetch_status = 0
	begin
		set @birthdate = dateadd(d, cast(floor(rand() * @countdays) + 1 as int), @minbirthdate);
		
		update person
		set birthdtm = @birthdate
		,[UPDATEDTM] = getdate()
		where personid = @personid;
		
		fetch next from cBirthdate into @personid;
	end;
	
	set nocount off;
	
end;


GO


