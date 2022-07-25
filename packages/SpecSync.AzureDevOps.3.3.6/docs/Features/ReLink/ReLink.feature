@re-link
@notsupported-tfs2017 @notsupported-tfs2018 @notsupported-ado2019
Feature: Re-link

Clones the connected Test Cases so that you can manage multiple versions of the 
same test-set. This might be useful when you need to support multiple releases.

Clone docs in ADO: https://docs.microsoft.com/en-us/azure/devops/test/copy-clone-test-items?view=azure-devops&tabs=browser

Process:
- Use Azure DevOps Clone Test Plan operation
- Invoke the SpecSync "re-link" command with a Clone Operation Id (if known) OR 
  without for auto detection.
  - The Clone Operation Id can be taken from the 'opId' agrument of the ADO 
    links after the clone operation, e.g. 
	https://dev.azure.com/specst/stpmanual02/_testPlans/define?planId=210957&opId=5&suiteId=210969
  - When the command has been invoked without a Clone Operation Id (auto 
    detection), SpecSync tries to find a single Clone Operation by looking at 
	the links of the first Test Case.
    - It lists all possible Clone Operation Ids if there are more.
  - SpecSync processes all scenarios and finds the cloned version of the Test 
    Cases
  - When found it changes the tags to point to the cloned versions. (Otherwise 
    it skips that scenario.)
  - Finally it updates the SpecSync configuration file with the new Test Plan 
    and Test Suite references if necessary.
- Review changes made in the feature files and the configuration file.
- Perform a push command to initialize the change tracking for the cloned Test Cases

Future ideas:
- Keep existing tag prefix and create a new one
- Rename existing tag prefix and create a new one

Rule: Should replace Test Case link tags to link the cloned Test Cases

@tc:625
Scenario: The scenario is updated for a cloned Test Plan
	Given there is an Azure DevOps project with an empty test suite 'BDD Scenarios'
	And the synchronizer is configured to add test cases to test suite 'BDD Scenarios'
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Plan of the Test Suite has been cloned in Azure DevOps
	When the SpecSync re-link is executed for the performed Clone
	Then the feature file in the local workspace should have been updated to contain
		"""
		@tc:[id-of-cloned-test-case]
		Scenario: Sample scenario
			When I do something
		"""

Rule: Should update configuration with the cloned Test Suites and Test Plans

Although not tested here, but the operation should also update the suite names as well in the 
configuration if they have changed. This is only possible using Test Suite Clone operations.

@tc:626
@bypass-ado-integration
Scenario: The Test Plan ID is set when the Suite was configured with name
	Given there is an Azure DevOps project with an empty test suite 'BDD Scenarios'
	And the synchronizer is configured as
		| setting                                                | value             |
		| remote/testSuite/name                                  | BDD Scenarios     |
		| publishTestResults/testSuite/name                      | BDD Scenarios     |
		| customizations/multiSuitePublishTestResults/enabled    | true              |
		| customizations/multiSuitePublishTestResults/testPlanId | [id-of-test-plan] |
	And there is a usual scenario that was already synchronized before
	And the Test Plan of the Test Suite has been cloned in Azure DevOps
	When the SpecSync re-link is executed for the performed Clone
	Then the configuration file should have been updated with
		| setting                                                | value                    |
		| remote/testSuite/testPlanId                            | [id-of-cloned-test-plan] |
		| publishTestResults/testSuite/testPlanId                | [id-of-cloned-test-plan] |
		| customizations/multiSuitePublishTestResults/testPlanId | [id-of-cloned-test-plan] |

@tc:627
@bypass-ado-integration
Scenario: The Suite IDs are replaced in the configuration and the Test Plan ID is set
	Given there is an Azure DevOps project with an empty test suite 'BDD Scenarios'
	And the synchronizer is configured as
		| setting                                                | value               |
		| remote/testSuite/id                                    | [id-of-test-suite]  |
		| publishTestResults/testSuite/id                        | [id-of-test-suite]  |
		| customizations/multiSuitePublishTestResults/enabled    | true                |
		| customizations/multiSuitePublishTestResults/testPlanId | [id-of-test-plan]   |
		| customizations/multiSuitePublishTestResults/suites[]   | #[id-of-test-suite] |
		| customizations/multiSuitePublishTestResults/suites[]   | other-suite-name    |
	And there is a usual scenario that was already synchronized before
	And the Test Plan of the Test Suite has been cloned in Azure DevOps
	When the SpecSync re-link is executed for the performed Clone
	Then the configuration file should have been updated with
		| setting                                                | value                      |
		| remote/testSuite/id                                    | [id-of-cloned-test-suite]  |
		| remote/testSuite/testPlanId                            | [id-of-cloned-test-plan]   |
		| publishTestResults/testSuite/id                        | [id-of-cloned-test-suite]  |
		| publishTestResults/testSuite/testPlanId                | [id-of-cloned-test-plan]   |
		| customizations/multiSuitePublishTestResults/testPlanId | [id-of-cloned-test-plan]   |
		| customizations/multiSuitePublishTestResults/suites[0]  | #[id-of-cloned-test-suite] |

Rule: Additional Work Item clones can be specified with a CSV file

@tc:698
Scenario: The linked Work Item has a clone
	Given there is an Azure DevOps project with an empty test suite 'BDD Scenarios'
	And there is a Product Backlog Item in the project
	And the synchronizer is configured as
		| setting                           | value |
		| synchronization/links[]/tagPrefix | pbi   |
	And the synchronizer is configured to add test cases to test suite 'BDD Scenarios'
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Plan of the Test Suite has been cloned in Azure DevOps
	And the Product Backlog Item has been cloned in Azure DevOps
	And there is a CSV file "wi-clones.csv" as
		"""
		source,target
		[id-of-pbi],[id-of-cloned-pbi]
		"""
	When the SpecSync re-link is executed for the performed Clone with
		| option             | value         |
		| workItemClonesFile | wi-clones.csv |
	Then the feature file in the local workspace should have been updated to contain
		"""
		@tc:[id-of-cloned-test-case] @pbi:[id-of-cloned-pbi]
		Scenario: Sample scenario
			When I do something
		"""