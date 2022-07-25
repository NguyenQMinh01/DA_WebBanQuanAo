@bypass-ado-integration
Feature: Disable local changes to synchronize scenarios on a build server

On the build server, we might not want to modify local feature
files, as it might not be possible to check them in.
Synchronization of the already linked scenarios should be possible though.

@tc:140
Scenario: Synchronization is configured to only update already synchronized scenarios
	Note: this will not perform local changes, so can better run on server
	Given there is an Azure DevOps project
	And there is an updated feature file that has been synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			Given there is something new
			When I do something new
			Then something new will happen

		Scenario: Not linked yet
			When I do something
		"""
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/disableLocalChanges | true  |
	When the local repository is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the feature file in the local workspace is not changed
