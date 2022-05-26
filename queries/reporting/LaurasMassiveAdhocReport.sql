-- This query more or less returns the content included in the Ad Hoc sheet of the Technitrain worksheet


-- Configuration Parameters: set these items here to control what happens there

DECLARE
    @ReportPeriodStart date,
    @ReportPeriodEnd date,
    @ReportRegion varchar(12),
    @ReportFundingProgram varchar(255);

SET @ReportPeriodStart = '10/1/2019';
SET @ReportPeriodEnd = '9/30/2020';

-- For these parameters, the query is coded to treat NULL as all and any value as the one value to match
-- The code that evaluates the parameters is down in the WHERE clause at the end of the query

SET @ReportRegion = NULL;
SET @ReportFundingProgram = 'USDA Technitrain 2019-2020';

-- End of Configuration

-- SELECT Section
SELECT TOP (100)
    p.Id AS "Project Id",
    p.[Name] AS "Project Name",
    f.[Name] AS "Funding Program",
    'TBA' AS "Location",
    'TBA' AS "Communities",
    'TBA' AS "Counties",
    s.[Name] AS "State",
    r.[Name] AS "Region",
    p.CongressionalDist AS "Congressional District",
    p.[Status] AS "Status",
    FORMAT(p.StartDate, 'd') AS "Start Date",
    FORMAT(p.EndDate, 'd') AS "End Date",
    infra.InfraType AS "Infrastructure Type",

    -- For each Outcome and Assistance Type, if the value is NULL, it wasn't assigned, so set to 0, otherwise set it to 1
    CASE
        WHEN pxo_compliance.ProjectId IS NULL THEN 0
        ELSE 1
    END AS "Compliance",
    CASE
        WHEN pxo_finstab.ProjectId IS NULL THEN 0
        ELSE 1
    END AS "Financial Stability",
    CASE
        WHEN pxo_coord.ProjectId IS NULL THEN 0
        ELSE 1
    END AS "Improved Coordination with ",
    CASE
        WHEN pxo_finstab.ProjectId IS NULL THEN 0
        ELSE 1
    END AS "Financial Stability",
    CASE
        WHEN pxa_leadership.ProjectId IS NULL THEN 0
        ELSE 1
    END AS "Community and Leadership Development",
    pxt_gis.StartDate AS "GIS Start",
    pxt_gis.TaskStatus AS "GIS Status",
    pxt_gis.EndDate AS "GIS End"
    
-- FROM & JOIN Section
FROM dbo.Project p
JOIN dbo.Funding f ON f.Id =p.FundingProgId
JOIN dbo.State s ON s.USPSCode = p.[State]
JOIN dbo.Region_X_State rxs ON rxs.StateId = s.Id
JOIN dbo.Region r ON r.Id = rxs.RegionId
JOIN dbo.InfraType infra ON infra.Id = p.InfraType

-- For each Outcome, join the P_X_O table with a unique name when the id matches that outcome

-- Id	Outcome	Definition
-- 1	Compliance w/ State & Fed Regulations
-- 2	Financial Sustainability
-- 3	Improved Coordination Among Communities
-- 4	Improved Environmental Health
-- 5	Improved Public Health
-- 6	Increased Managerial Capacity
-- 7	Improved Capacity of Community Facilities
-- 8	Improved Self-Defined Prosperity
-- 9	GIS Capability
-- 10	Improve awareness of and access to Healthy Foods
-- 11	Improve awareness of and access to Healthy Foods

LEFT JOIN dbo.Project_X_Outcome pxo_compliance ON pxo_compliance.ProjectId = p.Id AND pxo_compliance.OutcomeId = 1
LEFT JOIN dbo.Project_X_Outcome pxo_finstab ON pxo_finstab.ProjectId = p.Id AND pxo_finstab.OutcomeId = 2
LEFT JOIN dbo.Project_X_Outcome pxo_coord ON pxo_coord.ProjectId = p.Id AND pxo_coord.OutcomeId = 3
LEFT JOIN dbo.Project_X_Outcome pxo_env_health ON pxo_env_health.ProjectId = p.Id AND pxo_env_health.OutcomeId = 4
LEFT JOIN dbo.Project_X_Outcome pxo_pub_health ON pxo_pub_health.ProjectId = p.Id AND pxo_pub_health.OutcomeId = 5

-- For each Assistance Type, join the P_X_AT table with a unique name when the id matches that type

-- Id	AssistanceTypeName	Code
-- 1	Community and Leadership Development	A01
-- 2	Compliance and Environmental Health	A02
--
--          When someone has time on their hands, they should feel free to remove the detritus at the end of the remaining comment lines.
--
-- 3	Emergency Preparedness, Response & Recovery	A03	Assistance focused on helping a community recover from or prepare for natural or other environmentally or human-caused disasters	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 4	Facilities Development	A04	Assistance to secure new facilities, or for substantial expansion or renovation of existing facilities	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 5	Management and Finance	A05	Assistance to meet managerial and financial capacity guidelines, usually directed at system managers and directors of existing systems, as well as assistance to help set up management systems, bookkeeping, budgeting, rate setting, financial reporting, etc	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 6	Operations and Maintenance	A06	Assistance aimed at improving the day-to-day operation of the system, including diagnosis of operational problems/processes and operator training	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 7	RCAP Loan Fund	A07	Loans provided from an RCAP region's revloving loan fund to a community or other entity	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 8	Short Term Project	A08	Assistance provided to a community to resolve a specific short-term problem or meet a particular need. Long-term onsite assistance is not contemplated (best for fee-for-service contracts)	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 9	Source Water Protection	A09	For projects whose sole purpose is to protect drinking water supplies	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 10	Development Assistance	A10	Pre-development activities 	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 11	O&M	A11	Operations and maintenance 	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 12	M&F	A12	Management and finance 	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 13	Engineering Assistance	A13		2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 14	Environmental Review	A14		2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 15	Historic Preservation	A15		2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 16	Community Facilities Assistance	CF01	Assistance directed toward eligible USDA CF Borrowers	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 17	Economic Development Assistance	110	Technical Assistance to improve local economic capacity	2000-01-01 00:00:00.000	2000-01-01 00:00:00.000
-- 18	GIS Assistance	G01	Assist with GIS	2019-11-26 15:27:07.077	NULL

LEFT JOIN dbo.Project_X_AssistanceType pxa_leadership ON pxa_leadership.ProjectId = p.Id AND pxa_leadership.AssistanceTypeId = 1
LEFT JOIN dbo.Project_X_AssistanceType pxa_compliance_env_health ON pxa_compliance_env_health.ProjectId =p.Id AND pxa_compliance_env_health.AssistanceTypeId = 2

-- For a Task Type, do this
-- Or write some spiffy code to factor out the common pieces!

LEFT JOIN dbo.Project_X_Task pxt_gis ON pxt_gis.ProjectId = p.Id AND pxt_gis.TaskTypeId = 101

-- Constraint Section
WHERE
    p.StartDate BETWEEN @ReportPeriodStart AND @ReportPeriodEnd
-- Ask Felleman to explain how to constrain output based on particular parameters
    AND (@ReportFundingProgram IS NULL OR f.Name LIKE @ReportFundingProgram)
    AND (@ReportRegion IS NULL OR r.Name LIKE @ReportRegion)
;




-- All the tasks

--	Id	TaskCode	Task
--	1	T001	Assist with Application: Certificate of Convenience and Necessity
--	2	T002	Assist with Application: Form New Legal Entity or District
--	3	T003	Assist with Application: Grant or Loan Application
--	4	T004	Assist with Application: Permits or Licenses
--	5	T005	Assist with Application: Rate Increase
--	6	T006	Assist with Application: Water Rights/Source Approval
--	7	T007	Conduct Community Outreach: Public Educational Materials
--	8	T008	Conduct Community Outreach: Public Meeting
--	9	T009	Conduct Community Outreach: Recycling Program Kickoff
--	10	T010	Conduct Community Outreach: Stakeholder Group/Task Force
--	11	T011	Develop/Update Plan: Asset Management Plan
--	12	T012	Develop/Update Plan: Capability Assurance Plan
--	13	T013	Develop/Update Plan: Community Development Plan
--	14	T014	Develop/Update Plan: Corrective Action Plan
--	15	T015	Develop/Update Plan: Cross-Connection Control Plan
--	16	T016	Develop/Update Plan: Disaster/Debris Management Plan
--	17	T017	Develop/Update Plan: Emergency Response Plan
--	18	T018	Develop/Update Plan: Facility Closure Plan
--	19	T019	Develop/Update Plan: Financing Plan
--	20	T020	Develop/Update Plan: Integrated Solid Waste Management Plan
--	21	T021	Develop/Update Plan: Management Plan
--	22	T022	Develop/Update Plan: Operations and Maintenance Plan
--	23	T023	Develop/Update Plan: Recycling Plan
--	24	T024	Develop/Update Plan: Regional Collaboration Plan
--	25	T025	Develop/Update Plan: Sampling Plan
--	26	T026	Develop/Update Plan: Watershed/Source Water Protection Plan
--	27	T027	Develop/Update Plan: Wellhead Protection Plan
--	28	T028	Draw/Update Maps
--	29	T029	Facilitate Construction: Monitoring and Assistance
--	30	T030	Facilitate Construction: New Connections
--	31	T031	Facilitate Construction: Pre-Construction Planning/Budgeting
--	32	T032	Facilitate Construction: Repair/Replace/Purchase Equipment
--	33	T033	Facilitate Construction: Rights of Way/Easements
--	34	T034	Make Recommendations: Insurance Recommendation
--	35	T035	Make Recommendations: Process Recommendation
--	36	T036	Monitor Grant/Loan Funding: Administer Grant/Loan
--	37	T037	Monitor Grant/Loan Funding: Comply with Terms of Loan
--	38	T038	Monitor Grant/Loan Funding: Refinance Loan
--	39	T039	Negotiate/Establish Contract: Inter-Municipal Agreement
--	40	T040	Negotiate/Establish Contract: RFP/RFQ for Goods
--	41	T041	Negotiate/Establish Contract: RFP/RFQ for Services
--	42	T042	Negotiate/Establish Contract: Source Water Contract
--	43	T043	Negotiate/Establish Contract: Utility Management Contract
--	44	T044	Negotiate/Establish Contract: Waste Water Treatment Contract
--	45	T045	On-site Training: Board Training
--	46	T046	On-site Training: Community Training
--	47	T047	On-site Training: Operator Training
--	48	T048	On-site Training: Other Staff Training
--	49	T049	Perform Analysis: ADA Assessment
--	50	T050	Perform Analysis: Attitudes/Interest Survey
--	51	T051	Perform Analysis: Budget Analysis
--	52	T052	Perform Analysis: Energy Audit
--	53	T053	Perform Analysis: Environmental Assessment
--	54	T054	Perform Analysis: Feasibility Study
--	55	T055	Perform Analysis: Hydraulic Computer Analysis
--	56	T056	Perform Analysis: Hydrogeologic Survey
--	57	T057	Perform Analysis: Income Study
--	58	T058	Perform Analysis: Infiltration and Inflow Study
--	59	T059	Perform Analysis: Operations and Maintenance Evaluation
--	60	T060	Perform Analysis: Pressure Survey
--	61	T061	Perform Analysis: Private Well Risk Assessment
--	62	T062	Perform Analysis: Rate Study
--	63	T063	Perform Analysis: Sanitary Survey
--	64	T064	Perform Analysis: Septic Survey
--	65	T065	Perform Analysis: Source Water Assessment
--	66	T066	Perform Analysis: System Inspection
--	67	T067	Perform Analysis: Technical Engineering Evaluation
--	68	T068	Initial TMF Assessment
--	69	T069	Perform Analysis: Vulnerability Assessment
--	70	T070	Perform Analysis: Waste Characterization Study/Waste Audit
--	71	T071	Perform Analysis: Water Audit
--	72	T072	Prepare Report: Consumer Confidence Report
--	73	T073	Prepare Report: Financial Reports
--	74	T074	Prepare Report: Monthly Operational Report
--	75	T075	Prepare Report: Other Reports
--	76	T076	Prepare Report: State Environmental Quality Report
--	77	T077	Produce Materials: Bookkeeping/Billing System
--	78	T078	Produce Materials: Documentation
--	79	T079	Produce Materials: Manuals
--	80	T080	Produce Materials: Public Notices
--	81	T081	Produce Materials: Publications/Tools/Training Modules
--	82	T082	RCAP Plans: Annual Work Plan
--	83	T083	RCAP Plans: TA Work Plan/Community Service Agreement
--	84	T084	Revolving Loan Fund: Award Loan
--	85	T085	Revolving Loan Fund: Monitor Loan Recipient
--	86	T086	Write/Update Policies/Procedures: Job Descriptions/Hiring
--	87	T087	Write/Update Policies/Procedures: Managerial
--	88	T088	Write/Update Policies/Procedures: Operational
--	89	T089	Write/Update Policies/Procedures: Ordinances or Bylaws
--	90	T068	Closing TMF Assessment
--	91	T090	RCAP Plans: Project Service Period
--	92	CF01	Assist CF Borrower with SAMs Registration
--	93	CF02	Assist CF Borrower with DUNs Registration
--	94	CF03	Assist CF Borrower with CCR Registration
--	95	Eco-01	Conduct a Community Assessment
--	96	Eco-01	Conduct a Community Assessment
--	97	Eco-02	Form a Local Economic Development Leadership Team
--	98	Eco-03	Conduct a Wealthworks Value Chain Convening 
--	99	Eco-04	Develop Local Business Strategic Plan 
--	100	Eco-04	Develop Local Business Strategic Plan 
--	101	G001	Assist with GIS
--	102	G001	Assist with GIS
--	103	T091	Prepare Risk and Resiliency Assessment
--	104	ECO-05	Conduct a Local Food Access Survey
--	105	ECO-05	Conduct a Local Food Access Survey
--	106	ECO-06	Complete a community Healthy Foods Strategy