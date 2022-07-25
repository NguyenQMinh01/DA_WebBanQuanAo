@publishTestResults @bypass-ado-integration
Feature: Publish TRX Test Results

@tc:197
Scenario Outline: Publish a test result
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name   | className   | adapterTypeName   | test result name   | outcome |
		| <name> | <className> | <adapterTypeName> | <test result name> | Passed  |
	When the test result is published to configuration "Windows 8"
	Then the command should not fail
	And the there should be a test run registered with test results
		| test case ID      | outcome |
		| [id-of-test-case] | Passed  |
Examples: 
	| description | name                              | className                      | adapterTypeName                     | test result name |
	| SpecRun     | Sample scenario in Sample feature | MyProject.Sample feature       | executor://specrun/executorV3.0.216 | Sample scenario  |
	| MsTest      | SampleScenario                    | MyProject.SampleFeatureFeature | executor://mstestadapter/v2         | SampleScenario   |
	| xUnit       | Sample scenario                   | MyProject.SampleFeatureFeature | executor://xunit/VsTestRunner2/net  | Sample scenario  |
	| NUnit       | SampleScenario                    | MyProject.SampleFeatureFeature | executor://nunit3testexecutor/      | SampleScenario   |
	| NUnit(new)  | Sample scenario                   | MyProject.Sample feature       | executor://nunit3testexecutor/      | SampleScenario   |
Examples: SpecRun special
	| description                | name                                                  | className                                                                                                    | adapterTypeName                     | test result name |
	| with target                | Sample scenario in Sample feature (target: My Target) | MyProject.Sample feature                                                                                     | executor://specrun/executorV3.0.216 | Sample scenario  |
	| corrupt name               | Sample scenario                                       | MyProject.Sample feature                                                                                     | executor://specrun/executorV3.0.216 | Sample scenario  |
	| corrupt name and className | Sample scenario                                       | MyProject.Sample feature.#()::TestAssembly:NetFwSpecFlow24SpecRunProj/Feature:Sample+feature/Scenario:Sample | executor://specrun/executorV3.0.216 | Sample scenario  |

@tc:198
Scenario Outline: Publish Scenario Outline result
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario Outline: Sample scenario
			When I do <what>
		Examples:
			| what       |
			| this       |
			| that other |
		"""
	And there is a test result file with
		| name          | className   | adapterTypeName   | test result name     | outcome |
		| <methodName1> | <className> | <adapterTypeName> | <test result name 1> | Passed  |
		| <methodName2> | <className> | <adapterTypeName> | <test result name 2> | Failed  |
	When the test result is published to configuration "Windows 8"
	Then the command should not fail
	And the there should be a test run registered with test results
		| test case ID      | outcome |
		| [id-of-test-case] | Failed  |
Examples: 
	| description                     | adapterTypeName                     | className                      | methodName1                                                | test result name 1                                         | methodName2                                                      | test result name 2                                               |
	| SpecRun                         | executor://specrun/executorV3.0.216 | MyProject.Sample feature       | Sample scenario, this in Sample feature                    | Sample scenario, this                                      | Sample scenario, that other in Sample feature                    | Sample scenario, that other                                      |
	| MsTest                          | executor://mstestadapter/v2         | MyProject.SampleFeatureFeature | SampleScenario_This                                        | SampleScenario_This                                        | SampleScenario_ThatOther                                         | SampleScenario_ThatOther                                         |
	| xUnit                           | executor://xunit/VsTestRunner2/net  | MyProject.SampleFeatureFeature | Sample scenario(result: &quot;this&quot;, exampleTags: []) | Sample scenario(result: &quot;this&quot;, exampleTags: []) | Sample scenario(result: &quot;that other&quot;, exampleTags: []) | Sample scenario(result: &quot;that other&quot;, exampleTags: []) |
	| xUnit(allowRowTests=false)      | executor://xunit/VsTestRunner2/net  | MyProject.SampleFeatureFeature | Sample scenario: this                                      | Sample scenario: this                                      | Sample scenario: that other                                      | Sample scenario: that other                                      |
	| NUnit                           | executor://nunit3testexecutor/      | MyProject.SampleFeatureFeature | SampleScenario(&quot;this&quot;,null)                      | SampleScenario(&quot;this&quot;,null)                      | SampleScenario(&quot;that other&quot;,null)                      | SampleScenario(&quot;that other&quot;,null)                      |
	| NUnit(new)                      | executor://nunit3testexecutor/      | MyProject.Sample feature       | Sample scenario(this)                                      | Sample scenario(this)                                      | Sample scenario(that other)                                      | Sample scenario(that other)                                      |
	| NUnit(allowRowTests=false)      | executor://nunit3testexecutor/      | MyProject.SampleFeatureFeature | SampleScenario_This                                        | SampleScenario_This                                        | SampleScenario_ThatOther                                         | SampleScenario_ThatOther                                         |
	| NUnit(new, allowRowTests=false) | executor://nunit3testexecutor/      | MyProject.Sample feature       | Sample scenario: this                                      | Sample scenario: this                                      | Sample scenario: that other                                      | Sample scenario: that other                                      |
Examples: SpecRun special
	| description                | adapterTypeName                     | className                                                                                                    | methodName1                                                 | test result name 1    | methodName2                                                       | test result name 2          |
	| with target                | executor://specrun/executorV3.0.216 | MyProject.Sample feature                                                                                     | Sample scenario, this in Sample feature (target: My Target) | Sample scenario, this | Sample scenario, that other in Sample feature (target: My Target) | Sample scenario, that other |
	| corrupt name               | executor://specrun/executorV3.0.216 | MyProject.Sample feature                                                                                     | Sample scenario, this                                       | Sample scenario, this | Sample scenario, that other                                       | Sample scenario, that other |
	| corrupt name and className | executor://specrun/executorV3.0.216 | MyProject.Sample feature.#()::TestAssembly:NetFwSpecFlow24SpecRunProj/Feature:Sample+feature/Scenario:Sample | Sample scenario, this                                       | Sample scenario, this | Sample scenario, that other                                       | Sample scenario, that other |

Rule: Test attachments should be published

@tc:377
@notsupported-tfs2017
Scenario: The contains an attachment
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Scenario with attachment
			Given I do something
			When a test attachment is saved
		"""
	And there is a TRX test result file as
		"""
		<?xml version="1.0" encoding="utf-8"?>
		<TestRun id="7544fd0e-2b4d-4f5d-ab5e-54d4ff814e6e" name="myuser@MYMACHINE 2021-01-18 13:48:00" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010">
		  <TestSettings name="default" id="50cdb80f-9920-43f7-93ed-6ce58e2a1707">
			<Deployment runDeploymentRoot="myuser_MYMACHINE_2021-01-18_13_48_00" />
		  </TestSettings>
		  <Results>
			<UnitTestResult executionId="66f1401c-86a5-463d-8053-64fa62fa716b" testId="d9968b0a-5211-9673-7774-e546a15aadc9" 
				testName="ScenarioWithAttachment" testType="13cdc9d9-ddb5-4fa4-a97d-d965ccfc6d4b" 
				outcome="Passed" relativeResultsDirectory="66f1401c-86a5-463d-8053-64fa62fa716b">
			  <ResultFiles>
				<ResultFile path="MYMACHINE\sample_attachment.png" />
			  </ResultFiles>
			</UnitTestResult>
		  </Results>
		  <TestDefinitions>
			<UnitTest name="ScenarioWithAttachment" id="d9968b0a-5211-9673-7774-e546a15aadc9">
			  <Execution id="66f1401c-86a5-463d-8053-64fa62fa716b" />
			  <TestMethod adapterTypeName="executor://mstestadapter/v2" 
				className="MyProject.SampleFeatureFeature" name="ScenarioWithAttachment" />
			</UnitTest>
		  </TestDefinitions>
		</TestRun>
		"""
	And there is a file "myuser_MYMACHINE_2021-01-18_13_48_00\In\66f1401c-86a5-463d-8053-64fa62fa716b\MYMACHINE\sample_attachment.png" in the test result folder
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | attachments           |
		| [id-of-test-case] | sample_attachment.png |
