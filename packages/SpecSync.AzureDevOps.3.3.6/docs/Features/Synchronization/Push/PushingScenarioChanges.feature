Feature: Pushing scenario changes to Test Cases

Rule: Can create new Test Case work items from scenarios

@tc:145
Scenario: A new scenario is linked to a new Test Case
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
			Then something will happen
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                       |
		| Given there is something   |
		| When I do something        |
		| Then something will happen |
	And a tag "@tc:[id-of-new-test-case]" is added to the scenario in the local repository

@tc:146 @scenarioOutline
Scenario: A new scenario outline is linked to a new parametrized Test Case
	Given there is an Azure DevOps project
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
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                                      |
		| Given there is @something                 |
		| When I do @something                      |
		| Then @something will happen with @someone |
	And the Test Case contains the following parameter data 
		| something | someone |
		| foo       | Joe     |
		| bar       | Jill    |
		| boz       | Jack    | 
	And a tag "@tc:[id-of-new-test-case]" is added to the scenario outline in the local repository


Rule: Scenario outline parameters can be used in the steps

@tc:147 @scenarioOutline
Scenario: The scenario outline parameters are used in data tables
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario Outline: Sample scenario outline
			When I do something with a table
				| foo         | what | bar       |
				| <something> | xxx  | <someone> |
		Examples:
			| something | someone |
			| boz       | Jill    |
			| qux       | Jack    | 
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Sample scenario outline" is created in Azure DevOps
	And it the first test cases step text contains the following HTML table
		| foo        | what | bar      |
		| @something | xxx  | @someone |
	And the Test Case contains the following parameter data 
		| something | someone |
		| boz       | Jill    |
		| qux       | Jack    | 
	And a tag "@tc:[id-of-new-test-case]" is added to the scenario outline in the local workspace

@tc:148 @scenarioOutline
Scenario: The step contains an at character that needs to be escaped
	SpecSync escapes your scenario text in a way that it should not cause a conflict with ADO parameter syntax
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario Outline: Escaped
			When I do <some thing>that @needs escaping
		Examples:
			| some thing | 
			| foo        | 
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario Outline: Escaped" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                                         |
		| When I do @some-thing that '@'needs escaping |
	And the Test Case contains the following parameter data 
		| some-thing |
		| foo        |

Rule: Test Case is updates the linked Test Case when scenario changes

@tc:149
Scenario: Synchronize changes of an existing scenario to the linked Test Case
	The link is defined by a test-case tag, e.g. @tc:123
	Given there is an Azure DevOps project
	And there is an updated scenario that has been synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			Given there is something new
			When I do something new
			Then something new will happen
		"""
	When the local repository is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the Test Case contains the following test steps
		| step                           |
		| Given there is something new   |
		| When I do something new        |
		| Then something new will happen |
	And the feature file in the local repository is not changed

Rule: Gherkin features are represented in the Test Case

@tc:150
Scenario: Background steps are included in Test Case steps
	See "Configuring the format of the synchronized test cases"
	Alternative idea: shared steps
	Given there is an Azure DevOps project
	And there is a feature file in the local repository
		"""
		Feature: Sample feature

		Background: 
			Given there is something

		Scenario: Sample scenario
			When I do something
			Then something will happen
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case contains the following test steps
		| step                                 |
		| Background: Given there is something |
		| When I do something                  |
		| Then something will happen           |


@tc:151
Scenario: DataTable step argument is included in Test Case step text as HTML table
	See "Configuring the format of the synchronized test cases"
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Scenario with DataTable
			When I do something with a table
				| foo | bar |
				| boz | boo |
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Scenario with DataTable" is created in Azure DevOps
	And it the first test cases step text contains the following HTML table
		| foo | bar |
		| boz | boo |


@tc:152
Scenario: DocString step argument is included in Test Case step text as PRE text block
	Alternative idea: save it as an attachment if long
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Scenario with DocString
			When I do something with a table
				```
				long text
				with multiple lines
				  and indentation
				```
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Scenario with DocString" is created in Azure DevOps
	And it the first test cases step text contains the following PRE text
		"""
		long text
		with multiple lines
		  and indentation
		"""

Rule: Link-only mode: Push can be configured to only link new scenarios (do not change existing Test Cases)

@tc:634
Scenario: Only new scenarios are linked
	Given there is an Azure DevOps project
	And there is a feature file in the local workspace that was already synchronized before
		"""
		Feature: Sample feature
		@tc:[id-of-test-case]
		Scenario: Existing scenario
			When I do something
		"""
	When the feature file is updated to
		"""
		Feature: Sample feature
		@tc:[id-of-test-case]
		Scenario: Existing scenario updated
			When I do something

		Scenario: Not linked yet
			When I do something
		"""
	When the local repository is synchronized with push in link-only mode
	Then the scenario "Scenario: Not linked yet" was synchronized
	But the scenario "Scenario: Existing scenario updated" was not synchronized
	#Then a new Test Case work item "Scenario: Not linked yet" is created in Azure DevOps
