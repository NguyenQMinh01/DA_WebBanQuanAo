@publishTestResults @bypass-ado-integration
Feature: Publish Jest test results

Background: 
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'

@tc:396
Scenario: Publish a Jest Cucumber XML feature result
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario: Passing scenario
			When I do something

		@tc:[id-of-test-case-2]
		Scenario: Failing scenario
			When I do something
			Then the scenario fails

		@tc:[id-of-test-case-3]
		Scenario Outline: Outline with multiple examples
			Given the first parameter is "<param>"
			When <other param> is the second parameter
			Then the scenario <result>
		Examples:
			| param   | other param | result |
			| foo bar | 12          | passes |
			| baz     | 23          | fails  |
		"""
	And there is a Jest Cucumber XML test result file as
		"""
		<?xml version="1.0" encoding="UTF-8"?>
		<testsuites name="jest tests" tests="4" failures="2" errors="0" time="3.177">
		  <testsuite name="add two number" errors="0" failures="0" skipped="0" timestamp="2021-01-29T17:55:06" time="1.525" tests="3">
			<testcase classname="sample feature" name="sample feature;outline with multiple examples" time="0.023">
			</testcase>
			<testcase classname="sample feature" name="sample feature;outline with multiple examples" time="0.004">
		      <failure>Error: expect(received).toBe(expected)</failure>
			</testcase>
			<testcase classname="sample feature" name="sample feature;passing scenario" time="0.001">
			</testcase>
			<testcase classname="sample feature" name="sample feature;failing scenario" time="0.001">
		      <failure>Error: expect(received).toBe(expected) // Object.is equality
		      
		      Expected: 4
		      Received: 5
		      	at Object.stepFunction (D:\TestingTools\jest-cucumber\tests\step-definitions\sum.steps.ts:45:28)
		      	at D:\TestingTools\jest-cucumber\node_modules\jest-cucumber\src\feature-definition-creation.ts:134:65</failure>
			</testcase>
		  </testsuite>
		</testsuites>
		"""
	When the test result is published
	Then the command should succeed
	And the there should be a test run registered with test results
		| test case ID        | outcome | iteration outcomes | iteration parameters |
		| [id-of-test-case-1] | Passed  | (Passed)           | (n/a)                |
		| [id-of-test-case-2] | Failed  | (Failed)           | (n/a)                |
		| [id-of-test-case-3] | Failed  | (Passed),(Failed)  | (n/a),(n/a)          |
