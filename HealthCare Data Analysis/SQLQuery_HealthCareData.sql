USE Healthcare_DB
 	/*
	Question 1
	How many rows of data are in the FactTable that include 
	a Gross Charge greater than $100?
	*/

	Select Count(*) as 'CountofChargesOver100$'
	From FactTable
	Where FactTable.GrossCharge > 100


	/*
	Question 2
	How many unique patients exist is the Healthcare_DB?
	*/

	Select Count(Distinct PatientNumber) as 'UniquePatients'
	From FactTable

	/*
	Question 3
	How many CptCodes are in each CptGrouping?
	*/
	
	Select CptGrouping, Count(Distinct CptCode) as 'CPTCodes'
	From dimCptCode
	Group by CptGrouping
	Order by 2 desc

	/*
	Question 4
	How many providers have submitted a Medicare insurance claim?
	*/

	Select Count(Distinct ProviderNpi) as 'CountofProviders'
	From FactTable
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	INNER JOIN dimPayer
		on dimPayer.dimPayerPK = FactTable.dimPayerPK
	Where PayerName = 'Medicare'
	

	/*
	Question 5
	Calculate the Gross Collection Rate (GCR) for each
	LocationName - See Below 
	GCR = Payments divided GrossCharge
	Which LocationName has the highest GCR?
	*/
	
	Select 
		LocationName
		,FORMAT(-Sum(Payment) / Sum(GrossCharge), 'P1') as 'GCR'
	From FactTable
	INNER JOIN dimLocation
		on dimLocation.dimLocationPK = FactTable.dimLocationPK
	Group by LocationName
	Order by 2 desc

	
	/*
	Question 6
	How many CptCodes have more than 100 units?
	*/

	Select Count(*) as 'CountofCPT>100'
	From(
		Select CptCode, CptDesc, Sum(CPTUnits) as 'Units'
		From FactTable
		INNER JOIN dimCptCode
			on dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
		Group by CptCode, CptDesc
		Having SUM(CPTUnits) > 100
		) a

	/*
	Question 7
	Find the physician specialty that has received the highest
	amount of payments. Then show the payments by month for 
	this group of physicians. 
	*/

	Select ProviderSpecialty
		,-Sum(Payment) as 'Payments'
	From FactTable
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	INNER JOIN dimDate
		on dimDate.dimDatePostPK = FactTable.dimDatePostPK
	Group by ProviderSpecialty
	Order by 2 desc

	Select ProviderSpecialty
		,MonthYear
		,FORMAT(-Sum(Payment), '$#,###') as 'Payments'
	From FactTable
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	INNER JOIN dimDate
		on dimDate.dimDatePostPK = FactTable.dimDatePostPK
	Where ProviderSpecialty = 'Internal Medicine'
	Group by ProviderSpecialty, MonthYear, MonthPeriod
	Order by MonthPeriod asc

	/*
	Question 8
	How many CptUnits by DiagnosisCodeGroup are assigned to 
	a "J code" Diagnosis (these are diagnosis codes with 
	the letter J in the code)?
	*/

	Select DiagnosisCodeGroup
		,Sum(CPTUnits) as 'Units'
	From FactTable
	INNER JOIN dimDiagnosisCode
		on dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
	Where dimDiagnosisCode.DiagnosisCode LIKE '%J%'
	Group by DiagnosisCodeGroup
	Order by 2 desc
	
	/*
	Question 9
	You've been asked to put together a report that details 
	Patient demographics. The report should group patients
	into three buckets- Under 18, between 18-65, & over 65
	Please include the following columns:
		-First and Last name in the same column
		-Email
		-Patient Age
		-City and State in the same column
	*/

	Select 
		CONCAT(FirstName, '', LastName) as 'PatientName'
		,Email
		,PatientAge
		,case when PatientAge < 18 then 'Under 18'
			  when PatientAge between '18' and '65' then '18-65'
			  when PatientAge > 65 then 'Over 65'
			  Else null end as 'PatientAgeBucket'
		,CONCAT(City, '/', State) as 'City/State'
	From dimPatient
	Order by 3 desc

	/*
	Question 10
	How many dollars have been written off (adjustments) due
	to credentialing (AdjustmentReason)? Which location has the 
	highest number of credentialing adjustments? How many 
	physicians at this location have been impacted by 
	credentialing adjustments? 
	*/

	Select 
		LocationName
		,-Sum(Adjustment) as 'Adjustment'
		,Count(Distinct ProviderNpi) as 'CountofPhysician'
	From FactTable
	INNER JOIN dimTransaction
		on dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
	INNER JOIN dimLocation
		on dimLocation.dimLocationPK = FactTable.dimLocationPK
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	Where AdjustmentReason = 'Credentialing'
	Group by LocationName
	Order by 2 desc

	--Physicians needs to be credentialed
	Select 
		dimPhysician.ProviderNpi
		,dimPhysician.ProviderName
	From FactTable
	INNER JOIN dimTransaction
		on dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
	INNER JOIN dimLocation
		on dimLocation.dimLocationPK = FactTable.dimLocationPK
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	Where AdjustmentReason = 'Credentialing' and LocationName = 'Angelstone Community Hospital'


	/*
	Question 11
	What is the average patient age by gender for patients
	seen at Big Heart Community Hospital with a Diagnosis
	that included Type 2 diabetes? And how many Patients
	are included in that average?
	*/

	Select 
		PatientGender
		,Format(Avg(PatientAge), '#.#') as 'AverageAge'
		,Count(Distinct PatientNumber) as 'CountofPatients'
	From(
	Select Distinct 
		FactTable.PatientNumber
		,Convert(Decimal(6,2), PatientAge) as PatientAge
		,PatientGender
	From FactTable
	INNER JOIN dimPatient
		on dimPatient.dimPatientPK = FactTable.dimPatientPK
	INNER JOIN dimLocation
		on dimLocation.dimLocationPK = FactTable.dimLocationPK
	INNER JOIN dimDiagnosisCode
		on dimDiagnosisCode.dimDiagnosisCodePK = FactTable.dimDiagnosisCodePK
	Where LocationName = 'Big Heart Community Hospital'
		and DiagnosisCodeDescription LIKE '%type 2%'
		) a
	Group by PatientGender

	/*
	Question 12
	There are a two visit types that you have been asked
	to compare (use CptDesc).
		- Office/outpatient visit est
		- Office/outpatient visit new
	Show each CptCode, CptDesc and the associated CptUnits.
	What is the Charge per CptUnit? (Reduce to two decimals)
	*/

	Select 
		CptCode
		,CptDesc
		,Sum(CPTUnits) as 'CptUnits'
		,Format(Sum(GrossCharge) / Sum(CPTUnits), '$#.##') as 'ChargePerUnit'
	From FactTable
	INNER JOIN dimCptCode
		on dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
	Where CptDesc in ('Office/outpatient visit est', 'Office/outpatient visit new')
	Group by CptCode, CptDesc
	Order by 1, 2 desc
	
	/*
	Question 13
	Similar to Question 12, you've been asked to analysis
	the PaymentperUnit (NOT ChargeperUnit). You've been 
	tasked with finding the PaymentperUnit by PayerName. 
	Do this analysis on the following visit type (CptDesc)
		- Initial hospital care
	Show each CptCode, CptDesc and associated CptUnits.
	*/

	Select 
		CptCode
		,PayerName
		,CptDesc
		,Sum(CPTUnits) as 'CptUnits'
		,Format(-Sum(Payment) / Nullif(Sum(CPTUnits),0), '$#') as 'PaymentPerUnit'
	From FactTable
	INNER JOIN dimCptCode
		on dimCptCode.dimCPTCodePK = FactTable.dimCPTCodePK
	INNER JOIN dimPayer
		on dimPayer.dimPayerPK = FactTable.dimPayerPK
	Where CptDesc = 'Initial hospital care'
	Group by CptCode, PayerName, CptDesc
	Order by 2 desc

	/*
	Question 14
	Within the FactTable we are able to see GrossCharges. 
	You've been asked to find the NetCharge, which means
	Contractual adjustments need to be subtracted from the
	GrossCharge (GrossCharges - Contractual Adjustments).
	After you've found the NetCharge then calculate the 
	Net Collection Rate (Payments/NetCharge) for each 
	physician specialty. Which physician specialty has the 
	worst Net Collection Rate with a NetCharge greater than 
	$25,000? What is happening here? Where are the other 
	dollars and why aren't they being collected?
	*/

	Select 
		ProviderSpecialty
		,Format(GrossCharge,'$#,#') as GrossCharges
		,Format(ContractualAdj,'$#,#') as ContractualAdj
		,Format(NetCharges,'$#,#') as NetCharges
		,Format(Payments,'$#,#') as Payments
		,Format(Adjustments-ContractualAdj,'$#,#') as Adjustments
		,Format(-Payments/NetCharges, 'P0') as 'NetCollectionRate'
		,Format(AR, '$#,#') as AR
		,Format(AR/NetCharges, 'P0') as 'PercentInAR'
		,Format(-(Adjustments-ContractualAdj)/NetCharges, 'P0') as 'WriteOffPercent'
	From(
	Select 
		ProviderSpecialty
		,Sum(GrossCharge) as 'GrossCharge'
		,Sum(Case when AdjustmentReason = 'Contractual'
			then Adjustment
			Else Null End) as 'ContractualAdj'
		,Sum(GrossCharge) + 
			Sum(Case when AdjustmentReason = 'Contractual'
			then Adjustment
			Else Null End) as 'NetCharges'
		,Sum(Payment) as 'Payments'
		,Sum(Adjustment) as 'Adjustments'
		,Sum(AR) as 'AR'
	From FactTable
	INNER JOIN dimTransaction
		on dimTransaction.dimTransactionPK = FactTable.dimTransactionPK
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	Group by ProviderSpecialty ) a
	Where NetCharges > 25000
	Order by NetCollectionRate asc

	/*
	Question 15
	Build a Table that includes the following elements:
		- LocationName
		- CountofPhysicians
		- CountofPatients
		- GrossCharge
		- AverageChargeperPatients 
	*/

	Select 
		LocationName
		,Format(Count(Distinct ProviderNpi), '#,#') as 'CountofPhysicians'
		,Format(Count(Distinct dimpatient.PatientNumber), '#,#') as 'CountofPatients'
		,Format(Sum(GrossCharge), '$#,#') as 'Charges'
		,Format(Sum(GrossCharge)/Count(Distinct dimpatient.PatientNumber), '$#,#') as 'AverageChargeperPatients'
	From FactTable
	INNER JOIN dimLocation
		on dimLocation.dimLocationPK = FactTable.dimLocationPK
	INNER JOIN dimPhysician
		on dimPhysician.dimPhysicianPK = FactTable.dimPhysicianPK
	INNER JOIN dimPatient
		on dimPatient.dimPatientPK = FactTable.dimPatientPK
	Group by LocationName
