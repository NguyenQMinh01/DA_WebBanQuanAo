Feature: Linking Work Items and other artifacts using tags

Synchronizing special work-item tags (e.g. @story:123) to work item links in test cases

Rule: Establish work item links based on scenario tags

@tc:155
Scenario: A work item link tag added to the scenario
	Given there is an Azure DevOps project with a Bug
	And the synchronizer is configured as
		| setting                           | value |
		| synchronization/links[]/tagPrefix | bug   |
	And a @bug tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @bug:[id-of-bug]
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the Test Case should be linked to the Bug

@tc:156
Scenario: A work item link tag added to the feature
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a feature file in the local workspace that was already synchronized before
		"""
		@wi:[id-of-pbi]
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item

Rule: Links created by SpecSync are removed when the link tag is removed, but existing links or links that are manually added are preserved

@tc:157
Scenario: The work item tag is removed from the scenario
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
		"""
	Then the test case should not be linked to the Product Backlog Item

@tc:574
Scenario: The manually linked work items are not removed
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a Bug in the project
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case has got the Bug linked from Azure DevOps
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
		"""
	Then the Test Case should be still linked to the Bug

@tc:575
Scenario: Existing link synchronization is overtaken once linked with a tag
	Given there is an Azure DevOps project with a Bug
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case has got the Bug linked from Azure DevOps
	And the scenario was updated and synchronized as
		"""
		@tc:[id-of-test-case] @wi:[id-of-bug]
		Scenario: Sample scenario updated with the link
			When I do something
		"""
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario removed link tag
			When I do something
		"""
	Then the test case should not be linked to the Bug


Rule: Adding a work item link should trigger an update

@tc:159
Scenario: Only a work item link tag is added
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the test case is linked to the PBI work item

Rule: Multiple prefixes can be linked

@tc:158
Scenario: A product backlog link and a bug link tag is added to the scenario
	Given there is an Azure DevOps project
	And there is a Product Backlog Item in the project
	And there is a Bug in the project
	And there is a scenario in the local workspace that was already synchronized before
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi] @bug:[id-of-bug]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | pbi   |
		| synchronization/links[1]/tagPrefix | bug   |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item
	And the Test Case should be linked to the Bug

Rule: Link type can be specified

@tc:160
Scenario: "Tests" link is created by default
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a scenario in the local workspace that was already synchronized before
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/links[0]/tagPrefix | wi    |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item as 'Tests'

@tc:161
Scenario: The work item is linked as "Parent"
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a scenario in the local workspace that was already synchronized before
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                               | value  |
		| synchronization/links[0]/tagPrefix    | wi     |
		| synchronization/links[0]/relationship | Parent |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item as 'Parent'

@tc:162
Scenario: The link type has changed
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a scenario in the local workspace that was already synchronized before
		"""
		@tc:[id-of-test-case] @wi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                               | value |
		| synchronization/links[0]/tagPrefix    | wi    |
		| synchronization/links[0]/relationship | Tests |
	When the local workspace is synchronized with push
	Given the synchronizer is configured as
		| setting                               | value  |
		| synchronization/links[0]/tagPrefix    | wi     |
		| synchronization/links[0]/relationship | Parent |
	And the synchronizer is configured to force updates
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item as 'Parent'

Rule: Pull Requests can be linked

@tc:390
Scenario: A Pull Request link tag added to the scenario
	Given there is an Azure DevOps project with a Pull Request
	And there is a scenario in the local workspace that was already synchronized before
		"""
		@tc:[id-of-test-case] @pr:[existing-pull-request]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                               | value        |
		| synchronization/links[0]/tagPrefix    | pr           |
		| synchronization/links[0]/relationship | Pull Request |
	When the local workspace is synchronized with push
	Then the test case is linked to the Pull Request work item
