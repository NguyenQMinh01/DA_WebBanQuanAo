@publishTestResults @bypass-ado-integration
Feature: Publish Cucumber.js Test Results

Background: 
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And there is a feature file that was already synchronized before
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

@tc:354
Scenario: Publish a Cucumber.js JSON feature result
	Given there is a Cucumber.js JSON test result file as
		"""
        [
          {
            "keyword": "Feature",
            "name": "Sample feature",
            "line": 1,
            "id": "sample-feature",
            "tags": [],
            "uri": "features\\SpecSyncSample.feature",
            "elements": [
              {
                "id": "sample-feature;passing-scenario",
                "keyword": "Scenario",
                "line": 4,
                "name": "Passing scenario",
                "tags": [
                  {
                    "name": "@foo",
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
                    "match": {
                      "location": "features\\step_definitions\\steps.js:10"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 1000000
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
                    "name": "@bar",
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
                    "match": {
                      "location": "features\\step_definitions\\steps.js:10"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 0
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "Then ",
                    "line": 10,
                    "name": "the scenario fails",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:13"
                    },
                    "result": {
                      "status": "failed",
                      "duration": 1000000,
                      "error_message": "AssertionError: \nExpected: is \"expected\"\n     but: was \"actual\"\n    + expected - actual\n\n    -actual\n    +expected\n\n    at World.<anonymous> (W:\\SpecSync\\Integrations\\specsync-sample-cucumberjs\\features\\step_definitions\\steps.js:14:3)"
                    }
                  }
                ]
              },
              {
                "id": "sample-feature;outline-with-multiple-examples",
                "keyword": "Scenario",
                "line": 19,
                "name": "Outline with multiple examples",
                "tags": [],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "Given ",
                    "line": 14,
                    "name": "the first parameter is \"foo bar\"",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:4"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 0
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 15,
                    "name": "12 is the second parameter",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:7"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 0
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "Then ",
                    "line": 16,
                    "name": "the scenario passes",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:17"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 0
                    }
                  }
                ]
              },
              {
                "id": "sample-feature;outline-with-multiple-examples",
                "keyword": "Scenario",
                "line": 20,
                "name": "Outline with multiple examples",
                "tags": [],
                "type": "scenario",
                "steps": [
                  {
                    "arguments": [],
                    "keyword": "Given ",
                    "line": 14,
                    "name": "the first parameter is \"baz\"",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:4"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 0
                    }
                  },
                  {
                    "arguments": [],
                    "keyword": "When ",
                    "line": 15,
                    "name": "23 is the second parameter",
                    "match": {
                      "location": "features\\step_definitions\\steps.js:7"
                    },
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
                    "match": {
                      "location": "features\\step_definitions\\steps.js:13"
                    },
                    "result": {
                      "status": "failed",
                      "duration": 0,
                      "error_message": "AssertionError: \nExpected: is \"expected\"\n     but: was \"actual\"\n    + expected - actual\n\n    -actual\n    +expected\n\n    at World.<anonymous> (W:\\SpecSync\\Integrations\\specsync-sample-cucumberjs\\features\\step_definitions\\steps.js:14:3)"
                    }
                  }
                ]
              }
            ]
          }
        ]        
        """
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | outcome | iteration outcomes | iteration step outcomes                       | iteration parameters                                                                           |
		| [id-of-test-case-1] | Passed  | (Passed)           | (Passed)                                      | (n/a)                                                                                          |
		| [id-of-test-case-2] | Failed  | (Failed)           | (Passed,Failed)                               | (n/a)                                                                                          |
		| [id-of-test-case-3] | Failed  | (Passed),(Failed)  | (Passed,Passed,Passed),(Passed,Passed,Failed) | (param: foo bar, other param: 12, result: passes),(param: baz, other param: 23, result: fails) |

@tc:355
Scenario: Publish a Cucumber.js JUnit XML feature result
    Iteration parameters cannot be detected from JUnit XML result
	Given there is a Cucumber.js JUnit XML test result file as
		"""
        <?xml version="1.0" encoding="UTF-8"?>
        <testsuites>
          <testsuite name="sample-feature;passing-scenario" tests="1" failures="0" skipped="0" errors="0" time="0.001">
            <properties>
              <property name="tag" value="@foo">
              </property>
            </properties>
            <testcase classname="i-do-something" name="I do something" time="0.001">
            </testcase>
          </testsuite>
          <testsuite name="sample-feature;failing-scenario" tests="2" failures="1" skipped="0" errors="0" time="0.001">
            <properties>
              <property name="tag" value="@bar">
              </property>
            </properties>
            <testcase classname="i-do-something" name="I do something" time="0.000">
            </testcase>
            <testcase classname="the-scenario-fails" name="the scenario fails" time="0.001">
              <failure message="AssertionError">AssertionError: 
        Expected: is &quot;expected&quot;
             but: was &quot;actual&quot;
            + expected - actual

            -actual
            +expected

            at World.&lt;anonymous&gt; (W:\SpecSync\Integrations\specsync-sample-cucumberjs\features\step_definitions\steps.js:18:3)</failure>
            </testcase>
          </testsuite>
          <testsuite name="sample-feature;outline-with-multiple-examples" tests="3" failures="0" skipped="0" errors="0" time="0.002">
            <properties>
            </properties>
            <testcase classname="the-first-parameter-is-&quot;foo-bar&quot;" name="the first parameter is &quot;foo bar&quot;" time="0.001">
            </testcase>
            <testcase classname="12-is-the-second-parameter" name="12 is the second parameter" time="0.000">
            </testcase>
            <testcase classname="the-scenario-passes" name="the scenario passes" time="0.001">
            </testcase>
          </testsuite>
          <testsuite name="sample-feature;outline-with-multiple-examples" tests="3" failures="1" skipped="0" errors="0" time="0">
            <properties>
            </properties>
            <testcase classname="the-first-parameter-is-&quot;baz&quot;" name="the first parameter is &quot;baz&quot;" time="0.000">
            </testcase>
            <testcase classname="23-is-the-second-parameter" name="23 is the second parameter" time="0.000">
            </testcase>
            <testcase classname="the-scenario-fails" name="the scenario fails" time="0.000">
              <failure message="AssertionError">AssertionError: 
        Expected: is &quot;expected&quot;
             but: was &quot;actual&quot;
            + expected - actual

            -actual
            +expected

            at World.&lt;anonymous&gt; (W:\SpecSync\Integrations\specsync-sample-cucumberjs\features\step_definitions\steps.js:18:3)</failure>
            </testcase>
          </testsuite>
        </testsuites>
        """
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | outcome | iteration outcomes | iteration step outcomes                       | iteration parameters |
		| [id-of-test-case-1] | Passed  | (Passed)           | (Passed)                                      | (n/a)                |
		| [id-of-test-case-2] | Failed  | (Failed)           | (Passed,Failed)                               | (n/a)                |
		| [id-of-test-case-3] | Failed  | (Passed),(Failed)  | (Passed,Passed,Passed),(Passed,Passed,Failed) | (n/a),(n/a)          |

@tc:356
@notsupported-tfs2017
Scenario: Console output is included as embeddings in Cucumber.js JSON feature result
	Given there is a Cucumber.js JSON test result file as
		"""
        [
          {
            "keyword": "Feature",
            "name": "Sample feature",
            "line": 1,
            "id": "sample-feature",
            "tags": [],
            "uri": "features\\SpecSyncSample.feature",
            "elements": [
              {
                "id": "sample-feature;passing-scenario",
                "keyword": "Scenario",
                "line": 4,
                "name": "Passing scenario",
                "tags": [
                  {
                    "name": "@foo",
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
                    "match": {
                      "location": "features\\step_definitions\\steps.js:10"
                    },
                    "result": {
                      "status": "passed",
                      "duration": 1000000
                    },
                    "embeddings": [
                        {
                            "data": "This is the test output, first line",
                            "mime_type": "text/plain"
                        },
                        {
                            "data": "This is a second line",
                            "mime_type": "text/plain"
                        }
                    ]
                  }
                ]
              }
            ]
          }
        ]        
        """
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | attachments                 |
		| [id-of-test-case-1] | Standard_Console_Output.log |

@tc:364
@notsupported-tfs2017
Scenario Outline: The result conatins embedded image
	Given there is a Cucumber.js JSON test result file as
		"""
        [
          {
            "keyword": "Feature",
            "name": "Sample feature",
            "line": 1,
            "id": "sample-feature",
            "tags": [],
            "uri": "features\\SpecSyncSample.feature",
            "elements": [
              {
                "id": "sample-feature;failing-scenario",
                "keyword": "Scenario",
                "line": 4,
                "name": "Failing scenario",
                "tags": [
                  {
                    "name": "@foo",
                    "line": 3
                  }
                ],
                "type": "scenario",
                "steps": [
                  {
                    "keyword": "When ",
                    "result": {
                      "status": "passed",
                      "duration": 1000000
                    }
                  },
                  {
                    "hidden": <from hidden step>,
                    "result": {
                      "status": "passed",
                      "duration": 4000000
                    },
                    "embeddings": [
                        {
                            "data": "[base64-png-image]",
                            "mime_type": "image/png"
                        }
                    ]
                  },
                ]
              }
            ]
          }
        ]        
        """
	And the synchronizer is configured as
		| setting                                  | value               |
		| synchronization/format/useExpectedResult | <useExpectedResult> |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | attachments       |
		| [id-of-test-case-2] | <attachment name> |
Examples: 
    | description                       | from hidden step | useExpectedResult | attachment name  |
    | from Before/After hook            | true             | false             | image1.png       |
    | from a usual Given/When/Then      | false            | false             | step2_image1.png |
    | from Then merged to previous When | false            | true              | step1_image1.png |
