@customization
Feature: Custom field updates

Rule: Sets fields when linking (test case creation) and updating (test case update)

@tc:173
Scenario: Updates custom field when linking
	Given there is an Azure DevOps project
	And the synchronizer is configured to use custom field updates as
		| field identifier   | value                   |
		| System.Description | Feature: {feature-name} |
	And there is a feature file in the local workspace
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in the project
	And the test case fields are set to the following values
		| field identifier   | value                   |
		| System.Description | Feature: Sample feature |

@tc:174
Scenario: Updates custom field when updating
	Given there is an Azure DevOps project
	And the synchronizer is configured to use custom field updates as
		| field identifier   | value                   |
		| System.Description | Feature: {feature-name} |
	And there is a feature file in the local workspace
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When I do something
		"""
	And the feature file has been synchronized already
	When the feature file is updated to
		"""
		Feature: Updated feature

		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated scenario"
	And the test case fields are set to the following values
		| field identifier   | value                    |
		| System.Description | Feature: Updated feature |


Rule: Update text can contain placeholders

@tc:175 @bypass-ado-integration
Scenario Outline: Supports different placeholders
	The full list of placeholders can be found at https://specsolutions.gitbook.io/specsync/features/push-features/customization-update-custom-test-case-fields-on-push#template-placeholders
	Given there is an Azure DevOps project
	And the synchronizer is configured to use custom field updates as
		| field identifier   | value         |
		| System.Description | <placeholder> |
	And there is a feature file "<feature file path>" in the local workspace
		"""
		Feature: Sample feature
		Feature description

		Rule: My business rule

		Scenario: Sample scenario
		Scenario description
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in the project
	And the test case fields are set to the following values
		| field identifier   | value   |
		| System.Description | <value> |
Examples: 
	| placeholder            | value                | feature file path |
	| {feature-name}         | Sample feature       | MyFeature.feature |
	| {feature-description}  | Feature description  | MyFeature.feature |
	| {scenario-name}        | Sample scenario      | MyFeature.feature |
	| {scenario-description} | Scenario description | MyFeature.feature |
	| {rule-name}            | My business rule     | MyFeature.feature |
Examples: path related
	| placeholder           | value                      | feature file path          |
	| {feature-file-name}   | MyFeature.feature          | MyFeature.feature          |
	| {feature-file-folder} |                            | MyFeature.feature          |
	| {feature-file-path}   | MyFeature.feature          | MyFeature.feature          |
	| {feature-file-name}   | MyFeature.feature          | Features\MyFeature.feature |
	| {feature-file-folder} | Features                   | Features\MyFeature.feature |
	| {feature-file-path}   | Features\MyFeature.feature | Features\MyFeature.feature |
Examples: source related
	| placeholder       | value                                                                                                                                             | feature file path |
	| {scenario-source} | Scenario: Sample scenario\nScenario description\n	When I do something                                                                             | MyFeature.feature |
	| {feature-source}  | Feature: Sample feature\nFeature description\n\nRule: My business rule\n\nScenario: Sample scenario\nScenario description\n	When I do something | MyFeature.feature |


Rule: Updates custom field even if scenario is otherwise up-to-date

@tc:176
Scenario: Updates custom field even if scenario is otherwise up-to-date
	Given there is an Azure DevOps project
	And the synchronizer is configured to use custom field updates as
		| field identifier   | value                               |
		| System.Description | Description: {scenario-description} |
	And there is a feature file in the local workspace
		"""
		Feature: Sample feature

		Scenario: Sample scenario
		This is the description
			When I do something
		"""
	And the feature file has been synchronized already
	When the feature file is updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
		This is the changed description
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the test case fields are set to the following values
		| field identifier   | value                                        |
		| System.Description | Description: This is the changed description |

		
Rule: Test Case history can also be set

@tc:363
Scenario: Updates Test Case history
	Given there is an Azure DevOps project
	And the synchronizer is configured to use custom field updates as
		| field identifier | value                          |
		| System.History   | Scenario name: {scenario-name} |
	And there is a feature file in the local workspace
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When I do something
		"""
	And the feature file has been synchronized already
	When the feature file is updated to
		"""
		Feature: Updated feature

		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated scenario"
	And the test case field "System.History" should contain "Scenario name: Updated scenario"
