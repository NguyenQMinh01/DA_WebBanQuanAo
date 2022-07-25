@testProjectFeatureFilesFolder:Features
Feature: Attachments

Rule: Files can be attached to the Test Case

@tc:515
Scenario: A file is attached to the Test Case
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @sometag @attachment:file1.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file file1.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachment:
		| name      |
		| file1.txt |
	And the Test Case should have the following tags: "sometag"

@tc:516
Scenario: Multiple files are attached to the Test Case
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And @attachment tags have been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:file1.txt @attachment:file2.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file file1.txt in the folder of the feature file
	And there is a file file2.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachments:
		| name      |
		| file1.txt |
		| file2.txt |

@tc:517 @bypass-ado-integration
Scenario: Custom tag prefixes can be used
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                   | value         |
		| synchronization/attachments/enabled       | true          |
		| synchronization/attachments/tagPrefixes[] | testData      |
		| synchronization/attachments/tagPrefixes[] | specification |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @testData:file1.txt @specification:file2.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file file1.txt in the folder of the feature file
	And there is a file file2.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain 2 attachments

@tc:518 @bypass-ado-integration
Scenario: Multiple attachments with the same file name causes synchronization errors
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And @attachment tags have been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:a/file1.txt @attachment:b/file1.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file a/file1.txt in the folder of the feature file
	And there is a file b/file1.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the synchronization should finish with errors
	And the log should contain "The file names of the attached files must be unique"

@tc:519 @bypass-ado-integration
Scenario: Non-existing attached file causes synchronization errors
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:no_such_file.txt
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the synchronization should finish with errors
	And the log should contain "Unable to attach file: Could not find file"

@tc:520 @bypass-ado-integration
Scenario: Underscore character is used in the scenario tag to represent spaces in file paths
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:folder_1/file_1.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file "folder 1/file 1.txt" in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachment:
		| name       |
		| file 1.txt |

Rule: The base folder of the attached files can be specified and uses the folder of the feature file by default

@tc:521 @bypass-ado-integration
Scenario: Attachment base folder is configured to a folder relative to the config file
	Given there is an Azure DevOps project
	And there is a file files/attachements/file_in_folder.txt in the local repository
	And the synchronizer is configured as
		| setting                                | value              |
		| synchronization/attachments/enabled    | true               |
		| synchronization/attachments/baseFolder | files/attachements |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:file_in_folder.txt
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachment:
		| name               |
		| file_in_folder.txt |

Rule: Attachments are removed from the Test Case if the attachment tag is removed from the scenario

@tc:522
Scenario: Attachment tag is removed if it was synchronized by SpecSync
	The attachments that were added in Azure DevOps manually should remain
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And there is a file file1.txt in the folder of the feature file
	And there is a file file2.txt in the folder of the feature file
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @attachment:file1.txt @attachment:file2.txt
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case has got an attachment attachment_to_keep.txt added from Azure DevOps
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] @attachment:file2.txt
		Scenario: Sample scenario
			When I do something
		"""
	And the local workspace is synchronized with push
	Then the Test Case should contain the following attachments:
		| name                   |
		| file2.txt              |
		| attachment_to_keep.txt |

Rule: Wildcards can be used in attachment tags to attach multiple files

@tc:523 @bypass-ado-integration
Scenario: Multiple files from the same folder are attached with a wildcard
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:file*.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file file1.txt in the folder of the feature file
	And there is a file file2.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachments:
		| name      |
		| file1.txt |
		| file2.txt |

@tc:524 @bypass-ado-integration
Scenario: Multiple files from subfolders are attached with a wildcard
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And a @attachment tag has been added to an existing synchronized scenario as:
		"""
		@tc:[id-of-test-case] @attachment:**/file*.txt
		Scenario: Sample scenario
			When I do something
		"""
	And there is a file a/file1.txt in the folder of the feature file
	And there is a file b/file2.txt in the folder of the feature file
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachments:
		| name      |
		| file1.txt |
		| file2.txt |

Rule: Updates of the attached files are tracked

@tc:526
Scenario: File change is detected
	The file change is detected even if the scenario was not changed otherwise.
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                             | value |
		| synchronization/attachments/enabled | true  |
	And there is a file Features/file1.txt
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case] @attachment:file1.txt
		Scenario: Sample scenario
			When I do something
		"""
	And the file Features/file1.txt has been changed
	When the local workspace is synchronized with push
	Then the Test Case should contain the following attachments:
		| name      |
		| file1.txt |
	And the log should contain "Attaching file"

Rule: Limitation: Files can only be attached to a Test Case, not a Test Case step
