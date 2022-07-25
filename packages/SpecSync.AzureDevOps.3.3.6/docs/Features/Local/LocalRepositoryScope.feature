@bypass-ado-integration
Feature: Local Repository Scope

The scenarios that are considered for synchronization in the local repository 
can be limited by specifying a local repository scope.

Scenarios that are out of the specified scope are not synchronized and not 
included to the remote Test Suite. (In contrast to filtering that also excludes
scenarios from synchronization, but they are added to the Test Suite.)

Scopes can be specified using:

- tag expressions, see [Tag expressions](TagExpressions.feature)

See also [Filters and scopes](https://specsolutions.gitbook.io/specsync/important-concepts/filters-and-scopes) 
in the documentation.

Rule: Out-of-scope scenarios are not synchronized

@tc:637
Scenario: Some scenarios are not part of synchronization
	Given there is an Azure DevOps project
	And there is a feature file in the local repository
		"""
		Feature: Sample feature

		@synchronized
		Scenario: Synchronized scenario
			When I do something

		Scenario: Non-synchronized scenario
			When I do something
		"""
	And the synchronizer is configured to scope scenarios tagged with "@synchronized"
	When the local repository is synchronized with push
	Then the following scenarios should be processed
		| scenario                            | synchronized |
		| Scenario: Synchronized scenario     | true         |
		| Scenario: Non-synchronized scenario | false        |

Rule: Out-of-scope scenarios are not added to Test Suite

Out of scope scenarios are not added (removed) from test suite. See feature "Test Suite Synchronization"

Rule: Local scope can be specified by tag expressions

@tc:243
Scenario: Only scenarios with specific tag scope are synchronized
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting    | value                                              |
		| local/tags | @finished and @bug:* and not (@manual or @ignored) |
	And there is a feature file in the local repository
		"""
		Feature: Sample feature

		@finished @bug:123
		Scenario: Finished scenario
			When I do something
		@manual @finished
		Scenario: Manual scenario
			When I do something
		@ignore
		Scenario: Ignored scenario
			When I do something

		Scenario: Unfinished scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then the following scenarios should be processed
		| scenario                      | synchronized |
		| Scenario: Finished scenario   | true         |
		| Scenario: Manual scenario     | false        |
		| Scenario: Ignored scenario    | false        |
		| Scenario: Unfinished scenario | false        |

Rule: Local scope can be specified by source file patterns

@tc:638
Scenario: Only scenarios in specific files are synchronized
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting             | value                                  |
		| local/sourceFiles[] | Folder1/*.feature and not **/B.feature |
		| local/sourceFiles[] | Folder3/*.feature                      |
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
	And there is a feature file "Folder3/D.feature" in the local repository
		"""
		Feature: D feature

		Scenario: Scenario D
			When I do something
		"""
	When the local repository is synchronized with push
	Then the following scenarios should be processed
		| scenario             | synchronized |
		| Scenario: Scenario A | true         |
		| Scenario: Scenario B | false        |
		| Scenario: Scenario C | false        |
		| Scenario: Scenario D | true         |
