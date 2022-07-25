Feature: Add new Test Cases to an Area or an Iteration

Background: 
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""

Rule: Test Cases can be created in a specific area

@tc:131
Scenario: Test case created in the root area by default
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the new Test Case is in the following area: '\'

@tc:130
Scenario: Create new Test Case in a specified area path
	Given the synchronizer is configured as
		| setting                        | value     |
		| synchronization/areaPath/mode  | setOnLink |
		| synchronization/areaPath/value | TestArea  |
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the new Test Case is in the following area: '\TestArea'

Rule: Test Cases can be created in a specific iteration

@tc:132
Scenario: Test case created in the root iteration by default
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the new Test Case is in the following iteration: '\'

@tc:133
Scenario: Create new Test Case in a specified iteration path
	Given the synchronizer is configured as
		| setting                             | value         |
		| synchronization/iterationPath/mode  | setOnLink     |
		| synchronization/iterationPath/value | TestIteration |
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the new Test Case is in the following iteration: '\TestIteration'
