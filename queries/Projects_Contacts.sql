SELECT Project.Name, 
Project.Status,
Project.StartDate, 
Project.EndDate, 
FundingName = Funding.Name, 
Project.PopServed, 
Project.LowIncomePop, 
Project.MinorityPop, 
Project.HouseHolds, 
Project.MedianIncome,
Project.ZipCodes, 
Project.State,
Region = Region.Name,
TAP = Project.OwnerFullname,
Contact.ContactType,
Contact.FirstName,
Contact.LastName,
Contact.Title,
Contact.Organization,
Contact.City,
Contact.Zip,
Contact.Email,
Contact.CellPhone,
Contact.OfficePhone,
Contact.Deactivated

FROM Project
JOIN State
	ON Project.State=State.USPSCode
JOIN Region_X_State
	ON State.Id = Region_X_State.StateId
JOIN Region
	ON Region.Id = Region_X_State.RegionId
JOIN Funding
	ON Funding.Id = Project.FundingProgId
JOIN Project_X_Contact
	ON Project.Id = Project_X_Contact.ProjectId
JOIN Contact
	ON Contact.Id = Project_X_Contact.ContactId
WHERE Region.Name = 'MAP'