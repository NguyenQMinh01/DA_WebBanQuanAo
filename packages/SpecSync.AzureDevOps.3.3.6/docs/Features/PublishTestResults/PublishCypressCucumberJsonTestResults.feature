@publishTestResults @bypass-ado-integration
Feature: Publish Cypress Cucumber JSON Test Results

Background: 
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'

@tc:357
Scenario: Publish a Cypress Cucumber JSON feature result
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
	And there is a Cypress Cucumber JSON test result file as
		"""
        [
          {
            "keyword": "Feature",
            "name": "Sample feature",
            "line": 1,
            "id": "sample-feature",
            "tags": [],
            "uri": "SpecSyncSample.feature",
            "elements": [
              {
                "id": "sample-feature;passing-scenario",
                "keyword": "Scenario",
                "line": 4,
                "name": "Passing scenario",
                "tags": [
                  {
                    "name": "@tc:1",
                    "line": 3
                  }
                ],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 5,
                    "name": "I do something",
                    "result": {
                      "status": "passed",
                      "duration": 87000000
                    }
                  }
                ]
              },
              {
                "id": "sample-feature;failing-scenario",
                "keyword": "Scenario",
                "line": 8,
                "name": "Failing scenario",
                "tags": [
                  {
                    "name": "@tc:2",
                    "line": 7
                  }
                ],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 9,
                    "name": "I do something",
                    "result": {
                      "status": "passed",
                      "duration": 28000000
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "Then ",
                    "line": 10,
                    "name": "the scenario fails",
                    "result": {
                      "status": "failed",
                      "duration": 9000000,
                      "error_message": "AssertionError: expected true to equal false\n    at Context.eval (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:171:19)\n    at Context.resolveAndRunStepDefinition (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:7147:9)\n    at Context.eval (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:6488:35)"
                    }
                  }
                ]
              },
              {
                "id": "sample-feature;outline-with-multiple-examples",
                "keyword": "Scenario",
                "line": 19,
                "name": "Outline with multiple examples",
                "tags": [
                  {
                    "name": "@tc:3",
                    "line": 12
                  }
                ],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "Given ",
                    "line": 14,
                    "name": "the first parameter is \"foo bar\"",
                    "result": {
                      "status": "passed",
                      "duration": 399000000
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 15,
                    "name": "12 is the second parameter",
                    "result": {
                      "status": "passed",
                      "duration": 2000000
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "Then ",
                    "line": 16,
                    "name": "the scenario passes",
                    "result": {
                      "status": "passed",
                      "duration": 2000000
                    }
                  }
                ]
              },
              {
                "id": "sample-feature;outline-with-multiple-examples",
                "keyword": "Scenario",
                "line": 20,
                "name": "Outline with multiple examples",
                "tags": [
                  {
                    "name": "@tc:3",
                    "line": 12
                  }
                ],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "Given ",
                    "line": 14,
                    "name": "the first parameter is \"baz\"",
                    "result": {
                      "status": "passed",
                      "duration": 18000000
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 15,
                    "name": "23 is the second parameter",
                    "result": {
                      "status": "passed",
                      "duration": 1000000
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "Then ",
                    "line": 16,
                    "name": "the scenario fails",
                    "result": {
                      "status": "failed",
                      "duration": 4000000,
                      "error_message": "AssertionError: expected true to equal false\n    at Context.eval (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:171:19)\n    at Context.resolveAndRunStepDefinition (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:7147:9)\n    at Context.eval (http://localhost:51638/__cypress/tests?p=cypress\\integration\\SpecSyncSample.feature:6488:35)"
                    }
                  }
                ]
              }
            ]
          }
        ]
        """
	When the test result is published
	Then the command should succeed
	And the there should be a test run registered with test results
		| test case ID        | outcome | iteration outcomes | iteration step outcomes                       | iteration parameters                                                                           |
		| [id-of-test-case-1] | Passed  | (Passed)           | (Passed)                                      | (n/a)                                                                                          |
		| [id-of-test-case-2] | Failed  | (Failed)           | (Passed,Failed)                               | (n/a)                                                                                          |
		| [id-of-test-case-3] | Failed  | (Passed),(Failed)  | (Passed,Passed,Passed),(Passed,Passed,Failed) | (param: foo bar, other param: 12, result: passes),(param: baz, other param: 23, result: fails) |
