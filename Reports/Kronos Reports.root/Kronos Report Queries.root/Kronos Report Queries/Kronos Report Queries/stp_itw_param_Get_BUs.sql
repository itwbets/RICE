SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter procedure [dbo].[stp_itw_param_Get_BUs]

	@resort varchar(2),
	@JDEABNumber varchar(10),
	@KronosUserName varchar(70),
	@UserType varchar(10) = 'User'

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/11/2010
	Parameters: @resort - The resort used to filter the list of BU returned
				@JDEABNumber - The JDE address book number of the user.
				@KronosUserName - The Kronos username of the user
				@UserType - The type of user requesting the data.  Superusers and Admins have
					special privilages and get all BUs returned for the resort in question.
	Description: Returns the list of available divisions for the desired JDE AB number.
	Example: exec dbo.stp_itw_param_Get_BUs ET, 1022023, 'etmfraser', User
	Revisions: MF 1/11/2010 1.0 Created
   =============================================*/
	set nocount on;
	
	declare @BUList table(
	BUName varchar(50));
	
	declare @WildCardList table(
	BUWildcard varchar(50));
	
	declare @DefaultPersonNum int, @BULabourLevelDefid int
	
	set @DefaultPersonNum = 1
	set @BULabourLevelDefid = 2
	
	if @UserType <> 'Admin' and @UserType <>'SuperUser'
	begin
		--Get BUs directly assigned to user
		insert into @bulist
		select lle.name as BU 
		from dbo.vp_personv42 p inner join dbo.prsnaccsassign paa
			on p.personid = paa.personid
		inner join dbo.llelabacctstmm lllas
			on paa.mgraccesslasid = lllas.laboracctsetid
		inner join dbo.laborlevelentry lle 
			on lllas.laborlevelentryid = lle.laborlevelentryid
		where p.personnum = @JDEABNumber 

		union 

		select lle.name as BU 
		from dbo.useraccount p inner join dbo.prsnaccsassign paa
			on p.useraccountid = paa.personid
		inner join dbo.llelabacctstmm lllas
			on paa.mgraccesslasid = lllas.laboracctsetid 
		inner join dbo.laborlevelentry lle 
			on lllas.laborlevelentryid = lle.laborlevelentryid
		where p.useraccountnm = @KronosUserName;
		
		
		--Get list of BU start numbers with wildcards
		insert into @WildCardList
		select replace(wild.wildcardcd, '*', '%')
		from dbo.laboracctset las inner join dbo.prsnaccsassign paa
			on las.laboracctsetid = paa.mgraccesslasid 
		inner join dbo.llewildcardmm wild
			on paa.mgraccesslasid = wild.laboracctsetid
		inner join dbo.vp_personv42 p
			on p.personid = paa.personid 
		where wild.laborleveldefid = @BULabourLevelDefid 
			and wildcardcd <> '%' 
			and p.personnum = @JDEABNumber 

		union 

		select replace(wild.wildcardcd, '*', '%')
		from dbo.laboracctset las inner join dbo.prsnaccsassign paa
			on las.laboracctsetid = paa.mgraccesslasid 
		inner join dbo.llewildcardmm wild
			on paa.mgraccesslasid = wild.laboracctsetid 
		inner join dbo.useraccount p 
			on p.useraccountid = paa.personid
		where wild.laborleveldefid = @BULabourLevelDefid 
			and wildcardcd <> '%' 
			and p.useraccountnm = @KronosUserName;
		
		select bu_code, bu_desc, '(' + bu_code + ') ' + bu_desc as bu_label
		from dbo.itw_bu_hierarchy h
		inner join
		(select distinct l.name 
		from dbo.laborlevelentry l inner join @WildCardList w
			on l.name like w.BUWildcard
		where l.laborleveldefid = @BULabourLevelDefid
		and l.inactive = 0
		and l.name not in ('0', '-')
		
		union 
		
		select buname from @bulist) t1
			on t1.name = h.bu_code
		where h.personnum = @DefaultPersonNum
		and h.resort_code = @resort
		order by cast(name as int);
	end;
	else
	begin
		SELECT bu_code, bu_desc, '(' + bu_code + ') ' + bu_desc as bu_label
		FROM dbo.LABORLEVELENTRY LABORLEVELENTRY inner join dbo.itw_bu_hierarchy h
			on LABORLEVELENTRY.name = h.bu_code
		WHERE (LABORLEVELENTRY.LABORLEVELDEFID = @BULabourLevelDefid) 
		AND (LABORLEVELENTRY.NAME not in ('0', '-')) 
		AND (LABORLEVELENTRY.INACTIVE = 0) 
		and personnum = @DefaultPersonNum
		and resort_code = @resort
		ORDER BY cast(LABORLEVELENTRY.NAME as int);
	end;
	
	
	set nocount off;
	
end;


GO
