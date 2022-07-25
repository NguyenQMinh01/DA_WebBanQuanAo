@sync-state
Feature: Setting Test Case State on change

Rule: Can set Test Case state when change synchronized

@tc:141
Scenario: Test Case state is set back to Design when updated
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                  | value  |
		| synchronization/state/setValueOnChangeTo | Design |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case state is set to 'Ready'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
		"""
	And SpecSync push is executed
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case state should be 'Design' 

Rule: State change can be limited to scenarios using tag expressions

@tc:386
Scenario Outline: State change is enabled/disabled with tag expression
	state changed for all scenarios by default
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                  | value            |
		| synchronization/state/setValueOnChangeTo | Design           |
		| synchronization/state/condition          | <tag expression> |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case state is set to 'Ready'
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
	| description                                           | tag expression  | result state |
	| state change restricted to a tag                      | @inprogress     | Design       |
	| tag expression can be used                            | not @inprogress | Ready        |
	| state not changed if expression is evaluated to false | @other          | Ready        |
