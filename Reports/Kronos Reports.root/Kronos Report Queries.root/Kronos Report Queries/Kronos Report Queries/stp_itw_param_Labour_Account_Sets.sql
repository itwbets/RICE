SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_itw_param_Labour_Account_Sets]

@resort varchar(2)

as

begin
/* =============================================
	Author: Matt Fraser
	Create date: 1/4/2010
	Parameters: @resort - The resort used to filter the job step list
	Description: Returns the list of labour accounts sets for the selected resort.
	Example: exec dbo.stp_itw_param_get_labour_account_sets 'WB'
	Revisions: MF 1/4/2010 1.0 Created
	           BK 2/23/2010 1.1 Added Distinct to select statement
   =============================================*/
	set nocount on;

	SELECT DISTINCT LAS.LABORACCTSETID, LAS.SHORTNM 
	FROM dbo.VP_PERSONV42 VP INNER JOIN 
	dbo.LABORACCTSET LAS ON VP.MGRACCESSLABORSET =  LAS.SHORTNM 
	WHERE (VP.HOMELABORLEVELNM1 LIKE @resort + '%') 
	AND (VP.MGRACCESSLABORSET IS NOT NULL) 
	AND (LAS.LABORACCTSETID > 0) 
	ORDER BY LAS.SHORTNM
	
	set nocount off;
	
end;
