@customization
Feature: Customization: Link on change

Rule: Creates links on change

@tc:475
Scenario: Creates link when linking scenario to a new Test Case
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is linked to the PBI work item

@tc:476
Scenario: Creates a link when scenario changes are synchronized
	Given there is an Azure DevOps project with a Product Backlog Item
	And an existing synchronized scenario has been changed by changing the scenario name to:
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item

@tc:477
Scenario: The scenario has been changed multiple times
	ADO does not support creating multiple links to the same target with the same link type
	Given there is an Azure DevOps project with a Product Backlog Item
	And an existing synchronized scenario has been changed by changing the scenario name to:
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	When the local workspace is synchronized with push
	And the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario again
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the command should succeed
	And the test case is linked to the PBI work item

@tc:478
Scenario: Creates multiple links
	Given there is an Azure DevOps project
	And there is a Product Backlog Item in the project
	And there is a Bug in the project
	And the synchronizer is configured as
		| setting                                       | value       |
		| customizations/linkOnChange/enabled           | true        |
		| customizations/linkOnChange/links[0]/targetId | [id-of-pbi] |
		| customizations/linkOnChange/links[1]/targetId | [id-of-bug] |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is linked to the PBI work item
	And the Test Case should be linked to the Bug


Rule: Supports different link types

@tc:479
Scenario: "Tests" link is created by default
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case is linked to the PBI work item as 'Tests'

@tc:480
Scenario: The work item is linked as "Parent"
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                                           | value       |
		| customizations/linkOnChange/enabled               | true        |
		| customizations/linkOnChange/links[0]/relationship | Parent      |
		| customizations/linkOnChange/links[0]/targetId     | [id-of-pbi] |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	Then the test case is linked to the PBI work item as 'Parent'

@tc:481
Scenario: Links to the current Pull Request on change
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                           | value                                  |
		| customizations/linkOnChange/enabled               | true                                   |
		| customizations/linkOnChange/links[0]/relationship | Pull Request                           |
		| customizations/linkOnChange/links[0]/targetId     | {env:SYSTEM_PULLREQUEST_PULLREQUESTID} |
	And the environment variable "SYSTEM_PULLREQUEST_PULLREQUESTID" is set to "[existing-pull-request]"
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	And the local repository is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated scenario"
	Then the test case is linked to the Pull Request work item

@tc:482
Scenario: The link type has changed
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                                           | value       |
		| customizations/linkOnChange/enabled               | true        |
		| customizations/linkOnChange/links[0]/relationship | Tests       |
		| customizations/linkOnChange/links[0]/targetId     | [id-of-pbi] |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	Given the synchronizer is configured as
		| setting                                           | value       |
		| customizations/linkOnChange/enabled               | true        |
		| customizations/linkOnChange/links[0]/relationship | Parent      |
		| customizations/linkOnChange/links[0]/targetId     | [id-of-pbi] |
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario again
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the test case is linked to the PBI work item as 'Parent'

Rule: Skip linking when target ID value is empty

@tc:483
Scenario: Does not create link when the value is empty
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                                      | value             |
		| customizations/linkOnChange/enabled          | true              |
		| customizations/linkOnChange/links[]/targetId | {env:LINK_TARGET} |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	And the environment variable "LINK_TARGET" is set to ""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the test case should not be linked to the Product Backlog Item

Rule: Does not override links created based on tags

@tc:484
Scenario: There is a tag-based work item link already
	Given there is an Azure DevOps project with a Product Backlog Item
	And the synchronizer is configured as
		| setting                               | value  |
		| synchronization/links[0]/tagPrefix    | pbi    |
		| synchronization/links[0]/relationship | Parent |
	And a @pbi tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @pbi:[id-of-pbi]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                           | value       |
		| customizations/linkOnChange/enabled               | true        |
		| customizations/linkOnChange/links[0]/targetId     | [id-of-pbi] |
		| customizations/linkOnChange/links[0]/relationship | Tests       |
	When the local workspace is synchronized with push
	Then the test case is linked to the PBI work item as 'Parent'


Rule: Enabling link-on-change customization does not make scenarios dirty

This rule ensures that you can use multiple configuration files, one with and one without 
a link-on-change config, but switching between the config files does not cause uneccessary 
updates. 
(E.g., for pull request builds, a special config can be used with the linking feature on.)

@tc:485
Scenario: Scenario with custom field updates was not changed
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a usual scenario that was already synchronized before
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	When the local workspace is synchronized with push
	Then the test case should not be changed

Rule: Format configuration changes should not create links

@tc:486
Scenario: The scenario has only changed because of format changes
	Given there is an Azure DevOps project with a Product Backlog Item
	And there is a scenario that was already synchronized before
		"""
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                      | value       |
		| customizations/linkOnChange/enabled          | true        |
		| customizations/linkOnChange/links[]/targetId | [id-of-pbi] |
	And the synchronizer is configured as
		| setting                            | value |
		| synchronization/format/prefixTitle | false |
	When the local workspace is synchronized with push
	Then the test case should not be linked to the Product Backlog Item
