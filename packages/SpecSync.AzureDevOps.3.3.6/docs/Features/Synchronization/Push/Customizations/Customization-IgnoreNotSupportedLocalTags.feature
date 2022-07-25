@customization @sync-tags
Feature: Ignore not supported local tags

In some Azure DevOps project tag creation is restricted: normal users 
cannot create new tags. This is a problem, because SpecSync would synchronize 
all sceanrio tags to Test Case tags and that might include new ones.

Rule: Should be able to specify supported scenario (local test case) tags and only those should be synchronized

@tc:560
Scenario: The scenario has tags that cannot be synchronized to Azure DevOps
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                                    | value          |
		| customizations/ignoreNotSupportedLocalTags/enabled         | true           |
		| customizations/ignoreNotSupportedLocalTags/supportedTags[] | @supported-tag |
	And there is a scenario in the local repository
		"""
		@supported-tag @not-supported-tag
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then the scenario "Scenario: Sample scenario" was synchronized
	And the new Test Case should have the following tags: "supported-tag"

Rule: Should be able to specify not supported scenario (local test case) tags and those should not be synchronized

@tc:600
Scenario: The scenario has tags that is specified as not supported
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                                       | value              |
		| customizations/ignoreNotSupportedLocalTags/enabled            | true               |
		| customizations/ignoreNotSupportedLocalTags/notSupportedTags[] | @not-supported-tag |
	And there is a scenario in the local repository
		"""
		@supported-tag @not-supported-tag
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then the scenario "Scenario: Sample scenario" was synchronized
	And the new Test Case should have the following tags: "supported-tag"
