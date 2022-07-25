@plugins @bypass-ado-integration
Feature: SpecSync Plugins

Rule: Can perform a push/update operation with custom local test case source

@tc:244
Scenario: Updates existing test case with custom local test case source
	Given there is an Azure DevOps project
	And the synchronizer is configured with a custom plugin
	And there is a new test case as
		| field | value       |
		| title | Custom test |
	And there is a custom local test case "Updated custom test" linked to the Test Case
	When the local workspace is synchronized with push
	Then the Test Case title is updated to "Updated custom test"

Rule: Can match to custom TRX test results

@tc:245
@publishTestResults
Scenario: Publish a TRX test result with custom mather
	The scenario shows that with a plugin a custom test result matcher can be configured. 
	As an example, in this case the test result contains the capital letters of the scenario name.
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And the synchronizer is configured with a custom test result matcher plugin
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Scenario With Capital Case
			When I do something
		"""
	And there is a test result file with
		| name | className | adapterTypeName   | test result name | outcome |
		| SWCC | SWCC()    | executor://custom | SWCC             | Passed  |
	When the test result is published
	Then the command should not fail
	And the there should be a test run registered with test results
		| test case ID      | outcome |
		| [id-of-test-case] | Passed  |

Rule: Can load custom test results

@tc:246
@publishTestResults
Scenario: Publish a custom test result
	The scenario shows that with a plugin a custom test result loader and matcher can be configured. 
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And the synchronizer is configured with a custom test result loader plugin
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Scenario With Capital Case
			When I do something
		"""
	And there is a Custom TXT test result file as
		"""
		SWCC,Passed
		"""
	When the test result is published
	Then the command should not fail
	And the there should be a test run registered with test results
		| test case ID      | outcome |
		| [id-of-test-case] | Passed  |
