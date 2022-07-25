Feature: Configuring the format of the synchronized test cases

Format options with defaults:
	* "useExpectedResult": false,
    * "syncDataTableAsText": false,
    * "prefixBackgroundSteps": true
	* "prefixTitle": true

Rule: Scenario and Scenario Outline prefix in the Test Case title can be omitted 

@tc:144
Scenario: Title of Test Case is not prefixed
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/format/prefixTitle | false |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When SpecSync push is executed
	Then a new Test Case work item "Sample scenario" is created in Azure DevOps

Rule: Then steps can be synchronized to the expected results field of the Test Case step with an optional default value

@tc:153
Scenario: Then steps are sycnhronized to the expected results field
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                  | value |
		| synchronization/format/useExpectedResult | true  |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
			And something else too
		"""
	When SpecSync push is executed
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                     | expected result            |
		| Given there is something |                            |
		| When I do something      | Then something will happen |
		|                          | And something else too     |

@tc:154 @infrastructure
Scenario: Detects steps in the ExpectedResult
	Given there is an Azure DevOps project
	And the Test Case history is ignored for up-to-date checks
	And the synchronizer is configured as
		| setting                                         | value |
		| synchronization/format/useExpectedResult        | true  |
		| synchronization/format/emptyExpectedResultValue | N/A   |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
			And something else too
		"""
	And the feature file has been synchronized already
	When SpecSync push is executed
	Then the Test Case should not be changed

@tc:474
Scenario: A configured value is used for empty action and expected results field
	In some processes the audiors require explicitly marking empty fields
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                         | value |
		| synchronization/format/useExpectedResult        | true  |
		| synchronization/format/emptyExpectedResultValue | N/A   |
		| synchronization/format/EmptyActionValue         | SKIP  |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
			And something else too
		"""
	When SpecSync push is executed
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                     | expected result            |
		| Given there is something | N/A                        |
		| When I do something      | Then something will happen |
		| SKIP                     | And something else too     |


Rule: Data Tables can be synchronized as plain text instead of HTML teble

@tc:143
Scenario: DataTable is synchronized as plain text
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                    | value |
		| synchronization/format/syncDataTableAsText | true  |
	And there is a scenario in the local repository
		"""
		Scenario: Scenario with DataTable
			When I do something with a table
				| foo | bar |
				| boz | boo |
		"""
	When SpecSync push is executed
	Then a new Test Case work item "Scenario: Scenario with DataTable" is created in Azure DevOps
	And it the first test cases step text contains the following PRE text
		"""
		| foo | bar |
		| boz | boo |
		"""

Rule: Background prefix in the Test Case steps can be omitted 

@tc:406
Scenario: Background steps are not prefixed in Test Case steps
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value |
		| synchronization/format/prefixBackgroundSteps | false |
	And there is a feature file in the local repository
		"""
		Feature: Sample feature

		Background: 
			Given there is something

		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                     |
		| Given there is something |
		| When I do something      |

Rule: Scenario outline parameters can be explicitly listed

@tc:597
@scenarioOutline
Scenario: The examples table contains a column that is not used in the steps so listed explicitly
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario Outline: Sample scenario outline
			When I call <someone>
		Examples:
			| not used | someone |
			| foo      | Joe     |
			| bar      | Jill    |
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                                                 |
		| Parameters: not used = @not-used, someone = @someone |
		| When I call @someone                                 |
	And the Test Case contains the following parameter data 
		| not-used | someone |
		| foo      | Joe     |
		| bar      | Jill    |

@tc:598
@scenarioOutline
Scenario: The parameter list step is always required
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value  |
		| synchronization/format/showParameterListStep | always |
	And there is a scenario in the local repository
		"""
		Scenario Outline: Sample scenario outline
			When I call <someone>
		Examples:
			| someone |
			| Joe     |
			| Jill    |
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                           |
		| Parameters: someone = @someone |
		| When I call @someone           |

@tc:599
@scenarioOutline
Scenario: The parameter list step is never wanted
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value |
		| synchronization/format/showParameterListStep | never |
	And there is a scenario in the local repository
		"""
		Scenario Outline: Sample scenario outline
			When I call <someone>
		Examples:
			| not used | someone |
			| foo      | Joe     |
			| bar      | Jill    |
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                 |
		| When I call @someone |
