@customization @sync-state
Feature: Reset Test Case state

Rule: Test Case state can be reset as a separate Test Case update when change synchronized

@tc:382
Scenario: Test Case state is set to Ready after updated
	Two updates: Test Case revision changes from 2 to 4
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                   | value |
		| customizations/resetTestCaseState/enabled | true  |
		| customizations/resetTestCaseState/state   | Ready |
	And the Test Case revision is 2
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
		"""
	And SpecSync push is executed
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case state should be 'Ready'
	And the Test Case revision should be 4

@tc:383
Scenario: State change is not performed on unchanged Test Case
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                   | value |
		| customizations/resetTestCaseState/enabled | true  |
		| customizations/resetTestCaseState/state   | Ready |
	And there is a usual scenario that was already synchronized before
	When the local workspace is synchronized with push
	Then the test case should not be changed

Rule: Reset Test Case state can be limited to scenarios using tag expressions

@tc:384
Scenario: State change is enabled/disabled with tag expression
	state changed for all scenarios by default
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                     | value            |
		| customizations/resetTestCaseState/enabled   | true             |
		| customizations/resetTestCaseState/state     | Ready            |
		| customizations/resetTestCaseState/condition | <tag expression> |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case state is set to 'Design'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		@inprogress
		Scenario: Updated sample scenario
			When I do something new
		"""
	And SpecSync push is executed
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case state should be '<result state>' 
Examples: 
	| description                                           | tag expression | result state |
	| state change restricted to a tag                      | @inprogress    | Ready        |
	| state not changed if expression is evaluated to false | @other         | Design       |

Rule: Reset Test Case state works in combination with set state on change

@tc:385
Scenario: Reset Test Case state is used together with set state on change
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		@ready
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                     | value  |
		| synchronization/state/setValueOnChangeTo    | Design |
		| synchronization/state/condition             | @ready |
		| customizations/resetTestCaseState/enabled   | true   |
		| customizations/resetTestCaseState/state     | Ready  |
		| customizations/resetTestCaseState/condition | @ready |
	And the Test Case state is set to 'Ready'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		@ready
		Scenario: Updated sample scenario
			When I do something new
		"""
	And SpecSync push is executed
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case state should be 'Ready'
