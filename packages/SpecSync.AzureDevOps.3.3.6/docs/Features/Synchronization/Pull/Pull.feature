@pull
Feature: Pull

Pull changes from Azure DevOps server to the local repository.

Rule: Changes can be pulled

@tc:207
Scenario: Pull a normal test case to a scenario
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When something happens with someone
		"""
	And the feature file has been synchronized already
	When the Test Case title is updated to 'Scenario: Updated scenario'
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When something happens with someone
		"""

Rule: Step changes should be applied to the scenario

@tc:208
Scenario: Steps are synchronized back to feature file
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario Outline: Sample scenario outline
			When <something> happens with <someone>

		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""
	And the feature file has been synchronized already
	When the test case steps are updated to 
		"""
		When @something really happens with @someone
		Then this is good for @someone
		"""
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Sample scenario outline
			When <something> really happens with <someone>
			Then this is good for <someone>

		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""

@tc:615
Scenario: Unchanged background steps are pulled
	The background steps are not included in the scenario
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		Background:
			Given there is something

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	When the test case steps are updated to 
		"""
		Background: Given there is something
		When I do something new
		"""
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		Background:
			Given there is something

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something new
		"""

@tc:616
Scenario: Background steps changed in Azure DevOps
	The changed background steps are not included in the scenario, but 
	a warning is displayed
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		Background:
			Given there is something

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	When the test case steps are updated to 
		"""
		Background: Given there is something changed
		When I do something new
		"""
	And the SpecSync pull is attempted to be executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		Background:
			Given there is something

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something new
		"""
	And the synchronization should finish with warnings
	And the log should contain "Background"
	And the log should contain "Given there is something changed"


Rule: Parameter value changes should be applied to the scenario outline

@tc:209
Scenario: Parameter values are synchronized back to Scenario Outline
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario Outline: Sample scenario outline
			When <something> happens with <someone>

		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""
	And the feature file has been synchronized already
	When the test case parameter data is updated to
		| something | someone |
		| one       | Tarzan  |
		| two       | Thomas  |
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Sample scenario outline
			When <something> happens with <someone>

		Examples:
			| something | someone |
			| one       | Tarzan  |
			| two       | Thomas  |
		"""

Rule: Title changes should be applied to the scenario

@tc:210
Scenario: Title is synchronized back to feature file
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario Outline: Sample scenario outline
			When <something> happens with <someone>

		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""
	And the feature file has been synchronized already
	When the Test Case title is updated to 'Scenario Outline: Updated scenario outline'
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Updated scenario outline
			When <something> happens with <someone>

		Examples:
			| something | someone |
			| foo       | Joe     |
			| bar       | Jill    |
			| boz       | Jack    | 
		"""

Rule: Data table changes should be applied to the scenario

@tc:211
Scenario Outline: Data Table is synchronized back
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And the synchronizer is configured as
		| setting                                    | value                 |
		| synchronization/format/syncDataTableAsText | <syncDataTableAsText> |
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When something happens with someone
				| something | someone |
				| foo       | Joe     |
				| bar       | Jill    |
				| boz       | Jack    | 
			But nothing more
		"""
	And the feature file has been synchronized already
	When the Test Case title is updated to 'Scenario: Updated scenario'
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When something happens with someone
				| something | someone |
				| foo       | Joe     |
				| bar       | Jill    |
				| boz       | Jack    | 
			But nothing more
		"""
Examples: 
	| description                     | syncDataTableAsText |
	| HTML table representation       | false               |
	| Plain-text table representation | true                |

Rule: Doc string changes should be applied to the scenario

@tc:212
Scenario: Doc String is synchronized back
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file in the local workspace that was not synchronized yet
		```
		Feature: Sample feature

		Scenario: Sample scenario
			When something happens with someone
				"""
				something, someone
				  somewhere
				"""
			But nothing more
		```
	And the feature file has been synchronized already
	When the Test Case title is updated to 'Scenario: Updated scenario'
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		```
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When something happens with someone
				"""
				something, someone
				  somewhere
				"""
			But nothing more
		```

Rule: Tag changes should be applied to the scenario

@tc:617
Scenario: Tags are synchronized back to feature file
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @mytag @oldtag
		Scenario: Sample scenario
			When I do something
		"""
	When the Test Case tags are updated to "mytag, othertag"
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to contain
		"""
		@tc:[id-of-test-case]
		@mytag @othertag
		Scenario: Sample scenario
			When I do something
		"""

@tc:618
Scenario: Some feature and rule tags changed in Azure DevOps
	Inherited tags (from feature or rule) are not re-added to the scenario, but 
	disappeared inherited tags are not removed from the parent headers but a warning is shown.
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And there is a feature file that was already synchronized before
		"""
		@unchanged_featuretag @removed_featuretag
		Feature: Sample feature

		@unchanged_ruletag @removed_ruletag
		Rule: My Rule

		@tc:[id-of-test-case]
		@mytag @oldtag
		Scenario: Sample scenario
			When I do something
		"""
	When the Test Case tags are updated to "unchanged_featuretag, unchanged_ruletag, mytag, othertag"
	And the SpecSync pull is attempted to be executed
	Then the feature file in the local workspace should have been updated to
		"""
		@unchanged_featuretag @removed_featuretag
		Feature: Sample feature

		@unchanged_ruletag @removed_ruletag
		Rule: My Rule

		@tc:[id-of-test-case]
		@mytag @othertag
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronization should finish with warnings
	And the log should contain "@removed_featuretag"
	And the log should contain "@removed_ruletag"
