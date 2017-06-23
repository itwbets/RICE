SELECT distinct left(INTERFACE_CODE, 2) ResortCode, rtrim(left(interface_desc, charindex('-', interface_desc) - 2)) ResortName
FROM INTERFACE_CONFIGURATION
where INTERFACE_CODE like '__INN__JDE'