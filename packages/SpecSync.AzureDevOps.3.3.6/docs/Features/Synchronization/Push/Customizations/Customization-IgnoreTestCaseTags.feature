@customization @sync-tags
Feature: Ignore Test Case tags

Rule: Should be able to specify Test Case tags that should not be removed when the scenario is pushed

@tc:327
Scenario: The Test Case has ignored tags that is preserved during other tag changes
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                   | value       |
		| customizations/ignoreTestCaseTags/enabled | true        |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag @to-be-removed-tag
		Scenario: Sample scenario
			When I do something
		"""
	When the feature file is updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag @added-tag
		Scenario: Sample scenario
			When I do something
		"""
	And the tag "ignored-tag" is added to the Test Case
	And the local repository is synchronized with push
	Then the scenario "Scenario: Sample scenario" was synchronized
	And the Test Case should have the following tags: "mytag, ignored-tag, added-tag"

@tc:328
Scenario: The scenario has a Gherkin tag with the same name as an ignored tag
	We expect not to create duplicated tags on Test Case
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                   | value       |
		| customizations/ignoreTestCaseTags/enabled | true        |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag
		Scenario: Sample scenario
			When I do something
		"""
	When the feature file is updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag 
		@ignored-tag
		Scenario: Sample scenario
			When I do something
		"""
	And the tag "ignored-tag" is added to the Test Case
	And the local repository is synchronized with push
	Then the scenario "Scenario: Sample scenario" was synchronized
	And the Test Case should have the following tags: "mytag, ignored-tag"

Rule: Tail wildcard can be used for specifying Test Case tags with the same prefix

@tc:329
Scenario: Test Case tags with prefix are ignored using tail wildcard
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                   | value        |
		| customizations/ignoreTestCaseTags/enabled | true         |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag* |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag
		Scenario: Sample scenario
			When I do something
		"""
	When the tags "ignored-tag1, ignored-tag2" are added to the Test Case
	And the local repository is synchronized with push
	Then the scenario "Scenario: Sample scenario" was synchronized
	And the Test Case should have the following tags: "mytag, ignored-tag1, ignored-tag2"

Rule: Ignored Test Case tags should not be added to the scenario on pull

@tc:330
@pull
Scenario: The ingored tag is not added to the scenario on pull
	Given there is an Azure DevOps project
	And the synchronizer is configured to enable pull
	And the synchronizer is configured as
		| setting                                   | value       |
		| customizations/ignoreTestCaseTags/enabled | true        |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag
		Scenario: Sample scenario
			When I do something
		"""
	When the tag "ignored-tag" is added to the Test Case
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag
		Scenario: Sample scenario
			When I do something
		"""


@tc:331
@pull
Scenario: The ignored tag is removed from the scenario on pull during other tag changes
	Given there is an Azure DevOps project
	And the synchronizer is configured to enable pull
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag @to-be-removed-tag @ignored-tag
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                   | value       |
		| customizations/ignoreTestCaseTags/enabled | true        |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag |
	When the Test Case tags are updated to "mytag, ignored-tag, added-tag"
	When the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		@added-tag @mytag
		Scenario: Sample scenario
			When I do something
		"""

@tc:332
@pull
Scenario: The pull synchronization needs to be invoked with force to remove ignored tags
	Given there is an Azure DevOps project
	And the synchronizer is configured to enable pull
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case] @mytag @ignored-tag
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                   | value       |
		| customizations/ignoreTestCaseTags/enabled | true        |
		| customizations/ignoreTestCaseTags/tags[]  | ignored-tag |
	And the synchronizer is configured to force updates
	When the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		@mytag
		Scenario: Sample scenario
			When I do something
		"""
