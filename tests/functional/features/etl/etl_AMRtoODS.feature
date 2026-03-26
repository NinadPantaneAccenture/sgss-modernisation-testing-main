 Feature: Load AMR file to Aurora
 
  Background:
    Given the test environment is configured
    #And the Aurora test table is cleaned

#Web==================================================================================================================================
  @Web @LIMS @HappyPath 
  Scenario: Load valid AMR-LIMS file to Aurora [Web Channel]
    When a "valid AMR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-LIMS" file:
    | load_status  |
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-LIMS" file

  @Web @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Regex Errors Into Aurora [Web Channel]
    When a "regex error AMR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "regex error AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  @Web @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code AMR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  #@Web @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns AMR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-LIMS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@Web @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data AMR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-LIMS" file:
    | patient_nhs_number_valid_flag  |


  @Web @XLS @HappyPath 
  Scenario: Load valid AMR-XLS file to Aurora [Web Channel]
    When a "valid AMR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-XLS" file:
    | load_status  |

  @Web @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with Regex Errors Into Aurora [Web Channel]
    When a "regex error AMR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "regex error AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @Web @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code AMR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@Web @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns AMR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-XLS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@Web @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data AMR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-XLS" file:
    | patient_nhs_number_valid_flag  |
  
  
  @Web @FVE @HappyPath
  Scenario: Load valid AMR-FVE file to Aurora [Web Channel]
    When a "valid AMR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-FVE" file

  @Web @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code AMR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And I wait for the decryptor to process the file
    And the "incorrect lab code AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    Then the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "incorrect lab code AMR-FVE" file:
    | load_status  |
  
  @Web @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with Regex Errors Into Aurora [Web Channel]
    When a "regex error AMR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error AMR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table
  
  #@Web @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns AMR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-FVE" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@Web @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data AMR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-FVE" file:
    | patient_nhs_number_valid_flag  |
    
#SFTP==================================================================================================================================

  @SFTP @LIMS @HappyPath 
  Scenario: Load valid AMR-LIMS file to Aurora [SFTP Channel]
    When a "valid AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-LIMS" file:
    | load_status  |

  @SFTP @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  @SFTP @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  #@SFTP @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-LIMS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@SFTP @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-LIMS" file:
    | patient_nhs_number_valid_flag  |


  @SFTP @XLS @HappyPath 
  Scenario: Load valid AMR-XLS file to Aurora [SFTP Channel]
    When a "valid AMR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-XLS" file:
    | load_status  |

  @SFTP @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error AMR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @SFTP @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code AMR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@SFTP @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns AMR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-XLS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@SFTP @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data AMR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-XLS" file:
    | patient_nhs_number_valid_flag  |
  
  
  @SFTP @FVE @HappyPath
  Scenario: Load valid AMR-FVE file to Aurora [SFTP Channel]
    When a "valid AMR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-FVE" file

  @SFTP @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code AMR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
    | column_name         | expected_value |
    | load_status         | F              |
  
  @SFTP @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error AMR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error AMR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table
  
  #@SFTP @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns AMR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-FVE" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@SFTP @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data AMR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-FVE" file:
    | patient_nhs_number_valid_flag  |

#FileShare==================================================================================================================================

  @FS @LIMS @HappyPath 
  Scenario: Load valid AMR-LIMS file to Aurora [FileShare Channel]
    When a "valid AMR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-LIMS" file:
    | load_status  |

  @FS @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error AMR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  @FS @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code AMR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  #@FS @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns AMR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-LIMS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@FS @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data AMR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-LIMS" file:
    | patient_nhs_number_valid_flag  |


  @FS @XLS @HappyPath 
  Scenario: Load valid AMR-XLS file to Aurora [FileShare Channel]
    When a "valid AMR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-XLS" file:
    | load_status  |

  @FS @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error AMR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "regex error AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @FS @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code AMR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@FS @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns AMR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-XLS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@FS @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data AMR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-XLS" file:
    | patient_nhs_number_valid_flag  |
  
  
  @FS @FVE @HappyPath
  Scenario: Load valid AMR-FVE file to Aurora [FileShare Channel]
    When a "valid AMR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-FVE" file

  @FS @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code AMR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
    | column_name         | expected_value |
    | load_status         | F              |
  
  @FS @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error AMR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error AMR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table
  
  #@FS @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns AMR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-FVE" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@FS @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data AMR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-FVE" file:
    | patient_nhs_number_valid_flag  |

#Manual==================================================================================================================================

  @M @LIMS @HappyPath 
  Scenario: Load valid AMR-LIMS file to Aurora [Manual Channel]
    When a "valid AMR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-LIMS" file:
    | load_status  |

  @M @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error AMR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "regex error AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  @M @LIMS @WorkflowCheck 
  Scenario: Load a AMR-LIMS file with Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code AMR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  
  #@M @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns AMR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-LIMS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@M @LIMS @DatabaseCheck 
  Scenario: Load a AMR-LIMS file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data AMR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-LIMS" file:
    | patient_nhs_number_valid_flag  |


  @M @XLS @HappyPath 
  Scenario: Load valid AMR-XLS file to Aurora [Manual Channel]
    When a "valid AMR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid AMR-XLS" file:
    | load_status  |

  @M @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error AMR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "regex error AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @M @XLS @WorkflowCheck
  Scenario: Load a AMR-XLS file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code AMR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "incorrect lab code AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@M @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns AMR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-XLS" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@M @XLS @DatabaseCheck
  Scenario: Load a AMR-XLS file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data AMR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-XLS" file:
    | patient_nhs_number_valid_flag  |
  
  
  @M @FVE @HappyPath
  Scenario: Load valid AMR-FVE file to Aurora [Manual Channel]
    When a "valid AMR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid AMR-FVE" file

  @M @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code AMR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
    | column_name         | expected_value |
    | load_status         | F              |
  
  @M @FVE @WorkflowCheck
  Scenario: Load a AMR-FVE file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error AMR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error AMR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table
  
  #@M @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns AMR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns AMR-FVE" file:
    | patient_nhs_number_pop_flag  |
    | specimen_number_pop_flag     |
    | test_method_pop_flag         |
    | patient_postcode_pop_flag    |
    | specimen_type_pop_flag       |
    | organism_pop_flag            |
  
  #@M @FVE @DatabaseCheck
  Scenario: Load a AMR-FVE file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data AMR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data AMR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data AMR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data AMR-FVE" file:
    | patient_nhs_number_valid_flag  |