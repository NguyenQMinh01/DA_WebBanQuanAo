Feature: Mark Test Cases as Automated

Rule: Test Cases can be marked as automated

@tc:134
Scenario: Test Case is marked as automated
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is set to automated

@tc:137
Scenario: Test Cases are not marked as automated by default
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is not set to automated

@tc:139
Scenario: Associated automation is removed when configuration is changed
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
		"""
	And the feature file has been synchronized already
	And the synchronizer is configured to skip automation
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is not set to automated

@tc:558
Scenario: Automated test type can be specified
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value       |
		| synchronization/automation/enabled           | true        |
		| synchronization/automation/automatedTestType | Cucumber.js |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is set to automated with
		| automated test type |
		| Cucumber.js         |

@tc:559
Scenario: Choosing custom automation strategy fills test storage and test name based on the feature file
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value  |
		| synchronization/automation/enabled               | true   |
		| synchronization/automation/testExecutionStrategy | custom |
	And there is a feature file "MyFeature.feature" in the local repository
		"""
		Feature: My feature
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is set to automated with
		| automated storage | automated test name | automated test type |
		| MyFeature.feature | Sample scenario     | Gherkin             |

Rule: Marking Test Cases as automated can be limited to scenarios using tag expressions

@tc:387
Scenario Outline: Automation is only synchronized for selected scenarios with tag expression
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		@automated
		Scenario: Manual scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                              | value            |
		| synchronization/automation/enabled   | true             |
		| synchronization/automation/condition | <tag expression> |
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Manual scenario" is created in Azure DevOps
	And the test case is <result> to automated
Examples: 
	| description                                    | tag expression | result  |
	| marking restricted to a tag                    | @automated     | set     |
	| tag expression can be used                     | not @manual    | set     |
	| not marked if expression is evaluated to false | @other         | not set |
	| marked by default                              |                | set     |

	
@tc:136
@obsolete
Scenario: Automation is not synchronized for selected scenarios (by tag expression)
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		@manual @finished
		Scenario: Manual scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                | value                                   |
		| synchronization/automation/enabled     | true                                    |
		| synchronization/automation/skipForTags | @exploratory or (@manual and @finished) |
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Manual scenario" is created in Azure DevOps
	And the test case is not set to automated
	
Rule: Test Cases can be configured for Test Suite based test execution

See https://specsolutions.gitbook.io/specsync/features/test-result-publishing-features/support-for-azure-devops-test-plan-test-suite-based-test-execution

@tc:135
Scenario: Set Test Case automation details for synchronized scenarios
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value                   |
		| synchronization/automation/enabled               | true                    |
		| synchronization/automation/testExecutionStrategy | testSuiteBasedExecution |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is set to automated
	And the automation details are provided according to the test generated from the scenario

@tc:138
Scenario: Set test case automation for scenario outlines
	Note: requires a SpecFlow plugin
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value                                              |
		| synchronization/automation/enabled               | true                                               |
		| synchronization/automation/testExecutionStrategy | testSuiteBasedExecutionWithScenarioOutlineWrappers |
	And there is a scenario in the local repository
		"""
		Scenario Outline: Sample scenario outline
			Given there is <something>
			When I do <something>
			Then <something> will happen with <someone>
		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And the test case is set to automated
	And the automation details are provided according to the test generated from the scenario
