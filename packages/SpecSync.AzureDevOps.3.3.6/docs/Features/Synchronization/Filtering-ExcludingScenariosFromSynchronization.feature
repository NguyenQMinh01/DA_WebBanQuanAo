@bypass-ado-integration
Feature: Filtering - Excluding scenarios from synchronization

Filtered out scenarios are added (kept) in test suite. See feature "Test Suite Synchronization"

Rule: Can use tag expression to filter out scenarios from the synchronization

@tc:142
Scenario: Only selected scenarios are filtered (by tag expression)
	Given there is an Azure DevOps project
	And there is a feature file in the local repository
		"""
		Feature: Sample feature

		@done @current_sprint
		Scenario: Scenario in focus now
			When I do something

		@done
		Scenario: Other scenario
			When I do something
		"""
	And the synchronizer is provided with an option to filter scenario tags with "@current_sprint and @done"
	When the local repository is synchronized with push
	Then the scenario "Scenario: Scenario in focus now" was synchronized
	But the scenario "Scenario: Other scenario" was not synchronized

Rule: Can use source file expression to filter out scenarios from the synchronization

@tc:596
Scenario: Only selected scenarios are filtered (by source file expression)
	Given there is an Azure DevOps project
	And there is a feature file "Folder1/A.feature" in the local repository
		"""
		Feature: A feature

		Scenario: Scenario A
			When I do something
		"""
	And there is a feature file "Folder1/B.feature" in the local repository
		"""
		Feature: B feature

		Scenario: Scenario B
			When I do something
		"""
	And there is a feature file "Folder2/C.feature" in the local repository
		"""
		Feature: C feature

		Scenario: Scenario C
			When I do something
		"""
	And the synchronizer is provided with an option to filter source files with "Folder1/*.feature and not **/B.feature"
	When the local repository is synchronized with push
	Then the scenario "Scenario: Scenario A" was synchronized
	But the scenario "Scenario: Scenario B" was not synchronized
	But the scenario "Scenario: Scenario C" was not synchronized
