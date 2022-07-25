@dryRun
Feature: Dry-run support for synchronization

Rule: For new scenarios, the Test Case should not be created and the feature file should not be changed with dry-run mode

@tc:592
Scenario: New scenario is pushed in dry-run mode
	Given there is an Azure DevOps project
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push in dry-run mode
	Then no Test Case should have been created with title "Scenario: Sample scenario" in Azure DevOps
	And the feature file in the local workspace is not changed

Rule: For existing scenarios, the Test Case should not be updated with dry-run mode

@tc:593
Scenario: Updated scenario is pushed in dry-run mode
	Given there is an Azure DevOps project
	And there is an updated scenario that has been synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Updated scenario
			When I do something
		"""
	When the local repository is synchronized with push in dry-run mode
	Then the Test Case title should not be updated to "Scenario: Updated scenario" in Azure DevOps

Rule: The Test Suites should not be updated with dry-run mode

@tc:594
Scenario: A scenario that was not included in a Test Suite is pushed in dry-run mode
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And there is a scenario that was updated and synchronized as
		"""
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	When the local repository is synchronized with push in dry-run mode
	Then the test suite should be empty

Rule: Local workspace should not be changed during pull with dry-run mode

@tc:595
Scenario: A remote Test Case change is pulled in dry-run mode
	Given there is an Azure DevOps project
	And the synchronizer is configured to enable back syncing
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case title has been updated to 'Scenario: Updated scenario on remote'
	When the SpecSync pull is executed in dry-run mode
	Then the feature file in the local workspace is not changed
