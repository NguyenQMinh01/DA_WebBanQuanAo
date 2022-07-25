@publishTestResults
Feature: Publish test results

Background: 
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'

Rule: Should be able to publish test results

@tc:253
Scenario: Results of scenarios and scenario outlines are captured
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario: Passing scenario
			When the scenario pass

		@tc:[id-of-test-case-2]
		Scenario: Failing scenario
			When the scenario fail

		@tc:[id-of-test-case-3]
		Scenario Outline: Mixed results
			When the scenario <result>
		Examples:
			| result |
			| pass   |
			| fail   |
		"""
	And there is a test result file with
		| name              | className                      | outcome |
		| PassingScenario   | MyProject.SampleFeatureFeature | Passed  |
		| FailingScenario   | MyProject.SampleFeatureFeature | Failed  |
		| MixedResults_Pass | MyProject.SampleFeatureFeature | Passed  |
		| MixedResults_Fail | MyProject.SampleFeatureFeature | Failed  |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | outcome |
		| [id-of-test-case-1] | Passed  |
		| [id-of-test-case-2] | Failed  |
		| [id-of-test-case-3] | Failed  |

@tc:254
Scenario: The test result file is attached to the test run
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file "TestResult.trx" with
		| name           | className                      | methodName     | adapterTypeName             | test result name | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | SampleScenario | executor://mstestadapter/v2 | SampleScenario   | Passed  |
	When the test result is published successfully
	Then the there should be a test run registered with attachments
		| file name      | attachment type   | comment  |
		| TestResult.trx | TmiTestRunSummary | TRX File |

@tc:333
@notsupported-tfs2017
Scenario: The standard console output of the test is attached to the test result
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario: Sample scenario
			When the scenario pass

		@tc:[id-of-test-case-2]
		Scenario Outline: Sample scenario outline
			When the scenario <result>
		Examples:
			| result |
			| pass   |
			| fail   |
		"""
	And there is a test result file with
		| name                       | className                      | outcome |
		| SampleScenario             | MyProject.SampleFeatureFeature | Passed  |
		| SampleScenarioOutline_Pass | MyProject.SampleFeatureFeature | Passed  |
		| SampleScenarioOutline_Fail | MyProject.SampleFeatureFeature | Failed  |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | attachments                                                                   |
		| [id-of-test-case-1] | Standard_Console_Output.log                                                   |
		| [id-of-test-case-2] | Standard_Console_Output_Iteration1.log,Standard_Console_Output_Iteration2.log |

Rule: Additional files from the test result are attached to the Test Run result

@tc:639
@notsupported-tfs2017
Scenario: The contains an attachment
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When a test attachment is saved
		"""
	And there is a test result file that contains a test result for "Sample scenario" with an attachment "sample_attachment.png"
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | attachments                                       |
		| [id-of-test-case] | Standard_Console_Output.log,sample_attachment.png |


Rule: Should be able to load multiple test result files

@tc:358
Scenario: Results loaded from multiple files
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario: Passing scenario
			When the scenario pass

		@tc:[id-of-test-case-2]
		Scenario: Failing scenario
			When the scenario fail
		"""
	And there is a test result file "test-result1.trx" with
		| name              | className                      | outcome |
		| PassingScenario   | MyProject.SampleFeatureFeature | Passed  |
	And there is a test result file "test-result2.trx" with
		| name              | className                      | outcome |
		| FailingScenario   | MyProject.SampleFeatureFeature | Failed  |
	When the test result is published
	Then the command should succeed
	And the there should be a test run registered with test results
		| test case ID        | outcome |
		| [id-of-test-case-1] | Passed  |
		| [id-of-test-case-2] | Failed  |


Rule: Execution result details are published as Test Run iterations with step results

The step results are only published if the test result matcher can detect 
individual step results from the test results file. Otherwise step results are 
created without outcome.

Although for single scenarios there are no multiple iterations usually, we 
still create a single iteration for them to be able to display step results.

@tc:334
Scenario: Scenario outline example results are represented as iterations
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario Outline: Outline with multiple examples
			Given the first parameter is "<param>"
			When <other param> is the second parameter
			Then the scenario <result>
		Examples:
			| param   | other param | result |
			| foo bar | 12          | pass   |
			| baz     | 23          | fail   |

		@tc:[id-of-test-case-2]
		Scenario Outline: Outline with single example
			Given the first parameter is "<param>"
			When <other param> is the second parameter
			Then the scenario <result>
		Examples:
			| param   | other param | result |
			| baz     | 23          | fail   |
		"""
	And there is a test result file with
		| name                               | className                      | outcome | step outcomes        |
		| OutlineWithMultipleExamples_FooBar | MyProject.SampleFeatureFeature | Passed  | Passed,Passed,Passed |
		| OutlineWithMultipleExamples_Baz    | MyProject.SampleFeatureFeature | Failed  | Passed,Passed,Failed |
		| OutlineWithSingleExample_Baz       | MyProject.SampleFeatureFeature | Failed  | Passed,Passed,Failed |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | outcome | iteration outcomes | iteration step outcomes                       |
		| [id-of-test-case-1] | Failed  | (Passed),(Failed)  | (Passed,Passed,Passed),(Passed,Passed,Failed) |
		| [id-of-test-case-2] | Failed  | (Failed)           | (Passed,Passed,Failed)                        |

@tc:335
Scenario: Scenario results are represented as test results with a single iteration
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			Given the first parameter is "foo bar"
			When 12 is the second parameter
			Then the scenario fail
		"""
	And there is a test result file with
		| name           | className                      | outcome | step outcomes        |
		| SampleScenario | MyProject.SampleFeatureFeature | Failed  | Passed,Passed,Failed |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome | iteration outcomes | iteration step outcomes |
		| [id-of-test-case] | Failed  | (Failed)           | (Passed,Passed,Failed)  |

@tc:336
Scenario: Iteration parameters detected and published
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Outline with multiple examples
			Given the first parameter is "<param>"
			When <other param> is the second parameter
			Then the scenario <result>
		Examples:
			| param   | other param | result |
			| foo bar | 12          | pass   |
			| baz     | 23          | fail   |
		"""
	And there is a test result file with
		| name                               | className                      | outcome |
		| OutlineWithMultipleExamples_FooBar | MyProject.SampleFeatureFeature | Passed  |
		| OutlineWithMultipleExamples_Baz    | MyProject.SampleFeatureFeature | Failed  |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome | iteration outcomes | iteration parameters                                                                        |
		| [id-of-test-case] | Failed  | (Passed),(Failed)  | (param: foo bar, other param: 12, result: pass),(param: baz, other param: 23, result: fail) |

@tc:359
Scenario: Iteration parameters are matched and published to iteration steps
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Outline with examples
			When the first parameter is "<param1>"
			And <param2> is the second parameter but contains "<param1>" too
		Examples:
			| param1  | param2 | 
			| foo bar | 12     | 
		"""
	And there is a test result file with
		| name                               | className                      | outcome |
		| OutlineWithExamples_FooBar | MyProject.SampleFeatureFeature | Passed  |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome | iteration outcomes | iteration parameters          | iteration step parameters                         |
		| [id-of-test-case] | Passed  | (Passed)           | (param1: foo bar, param2: 12) | ((param1: foo bar),(param1: foo bar, param2: 12)) |


Rule: Additional details can be specified for the created Test Run

@tc:255
Scenario: Test run settings are specified
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the publishing is configured with
		| setting    | value      |
		| runName    | My run     |
		| runComment | My comment |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting        | value      |
		| Run name       | My run     |
		| Run comment    | My comment |

@tc:256
Scenario: Test result comment is provided
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case-1]
		Scenario: Sample scenario
			When I do something

		@tc:[id-of-test-case-2]
		Scenario Outline: Mixed results
			When the scenario <result>
		Examples:
			| result |
			| pass   |
			| fail   |
		"""
	And there is a test result file with
		| name              | className                      | outcome |
		| SampleScenario    | MyProject.SampleFeatureFeature | Passed  |
		| MixedResults_Pass | MyProject.SampleFeatureFeature | Passed  |
		| MixedResults_Fail | MyProject.SampleFeatureFeature | Failed  |
	And the publishing is configured with
		| setting           | value      |
		| testResultComment | My comment |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID        | comment                                                                |
		| [id-of-test-case-1] | My comment                                                             |
		| [id-of-test-case-2] | My comment;<br>MixedResults_Pass: Passed;<br>MixedResults_Fail: Failed |

Rule: Test Run is created as Automated if scenarios are sycnhronized as automated Test Cases

@tc:337
Scenario Outline: Test Run automation status is set based on whether scenarios are synchronized to automated test cases
	Given the synchronizer is configured to <synchronize to automated> automation
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting      | value                        |
		| Is Automated | <expected automation status> |
Examples: 
	| description                                                      | synchronize to automated | expected automation status |
	| scenarios are synchronized as automated Test Cases               | enable                   | true                       |
	| scenarios are synchronized as not automated Test Cases (default) | skip                     | false                      |

@tc:338
@notsupported-ado2019 @notsupported-tfs2018
Scenario Outline: Test Run automation status can be overridden (automation mismatch)
	This case might lead to automation mismatch error in older Azure DevOps servers
	Given the synchronizer is configured to <synchronize to automated> automation
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the publishing is configured with
		| setting  | value      |
		| Run Type | <run type> |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting      | value                        |
		| Is Automated | <expected automation status> |
Examples: 
	| description                                   | synchronize to automated | run type  | expected automation status |
	| Publish automated Test Cases as Manual        | enable                   | Manual    | false                      |
	| Publish non-automated Test Cases as Automated | skip                     | Automated | true                       |

Rule: The test run can be connected with an Azure DevOps build

@tc:257
Scenario: Build details are specified
	The synchronized Test Cases should be marked as "automated" otherwise SpecSync provides 
	a warning when the Test Run is associated with a build.
	Given the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the publishing is configured with
		| setting       | value                   |
		| buildNumber   | [existing-build-number] |
		| buildPlatform | x86                     |
		| buildFlavor   | Debug                   |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting        | value               |
		| Build Id       | [existing-build-id] |
		| Build platform | x86                 |
		| Build flavor   | Debug               |

@tc:656
Scenario: Automated test details are specified for the test results
	Azure DevOps can display a test execution history if the automated test details 
	are specified for the test result. Also the specified AutomatedStorage appears 
	as "Test file" filter in the "Tests" tab of the pipeline result.
	Given the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the publishing is configured with
		| setting       | value                   |
		| buildNumber   | [existing-build-number] |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome | automated storage | automated test type | automated test name                                       |
		| [id-of-test-case] | Passed  | MyAssembly.dll    | SpecFlow            | MyCompany.MyNamespace.SampleFeatureFeature.SampleScenario |


Rule: Inconclusive test result can be mapped

@tc:258
Scenario: Inconclusive is treated as skipped (NotExecuted)
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Mixed results
			When the scenario <result>
		Examples:
			| result       |
			| pass         |
			| inconclusive |
		"""
	And there is a test result file with
		| name                      | className                      | outcome      |
		| MixedResults_Pass         | MyProject.SampleFeatureFeature | Passed       |
		| MixedResults_Inconclusive | MyProject.SampleFeatureFeature | Inconclusive |
	And the publishing is configured with
		| setting             | value       |
		| treatInconclusiveAs | NotExecuted |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome |
		| [id-of-test-case] | Passed  |

Rule: The single test configuration is used for publishing if not specified

@tc:376
@notsupported-tfs2017 @notsupported-tfs2018 @notsupported-ado2019
Scenario: Test Configuration is not specified
	Given there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the publishing is configured with
		| setting    | value      |
		| runName    | My run     |
		| runComment | My comment |
	When the test result is published without specifying a Test Configuration
	Then the command should succeed