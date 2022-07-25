@infrastructure @bypass-ado-integration @specFlowCodeBehind
Feature: Generate feature file code-behind for SpecFlow v2

Background: 
	Given there is an Azure DevOps project
	And the synchronizer is configured to force generating feature file code-behinds

Rule: Code-behind should be generated on pull

@tc:287 @specFlowCodeBehind
Scenario: Local scenario changed by pull
	Given the synchronizer is configured to enable pull
	And there is a usual scenario that was already synchronized before
	When the Test Case title is updated to 'Scenario: Updated scenario'
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to include "Updated scenario"
	And the feature file code-behind file should have been updated

Rule: Code-behind should be generated on link

@tc:288
Scenario: Scenario is tagged with a Test Case link
	Given there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in the project
	Then a tag "@tc:[id-of-new-test-case]" should have been added to the scenario in the local workspace
	And the feature file code-behind file should have been updated

