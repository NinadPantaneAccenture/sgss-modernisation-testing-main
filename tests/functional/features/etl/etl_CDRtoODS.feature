Feature: Load CDR file to Aurora

  Background:
    Given the test environment is configured
  #And the Aurora test table is cleaned

  #Web==================================================================================================================================
  @Web @LIMS @HappyPath
  Scenario: Load valid CDR-LIMS file to Aurora [Web Channel]
    When a "valid CDR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid CDR-LIMS" file:
      | load_status |

  @Web @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with Regex Errors Into Aurora [Web Channel]
    When a "regex error CDR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "regex error CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
    And the "regex error CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "regex error CDR-LIMS" file:
      | load_status |

  @Web @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code CDR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
    And the "incorrect lab code CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "incorrect lab code CDR-LIMS" file:
      | load_status |

  @Web @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns CDR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-LIMS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  #@Web @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data CDR-LIMS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-LIMS" file:
      | patient_nhs_number_valid_flag       |
      | patient_dob_valid_flag              |
      | patient_age_years_valid_flag        |
      | lab_report_date_valid_flag          |
      | specimen_request_test_valid_flag    |
      | hospital_patient_no_valid_flag      |
      | patient_surname_valid_flag          |
      | specimen_request_feature_valid_flag |


  @Web @CSV @HappyPath
  Scenario: Load valid CDR-CSV file to Aurora [Web Channel]
    When a "valid CDR-CSV" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-CSV" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid CDR-CSV" file:
      | load_status |

  @Web @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with Regex Errors Into Aurora [Web Channel]
    When a "regex error CDR-CSV" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "regex error CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  #And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "regex error CDR-CSV" file:
  #| load_status  |

  @Web @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code CDR-CSV" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @Web @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns CDR-CSV" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-CSV" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @Web @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data CDR-CSV" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-CSV" file:
      | patient_nhs_number_valid_flag |


  @Web @XLS @HappyPath
  Scenario: Load valid CDR-XLS file to Aurora [Web Channel]
    When a "valid CDR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "valid CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-XLS" file

  @Web @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with Regex Errors Into Aurora [Web Channel]
    When a "regex error CDR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "regex error CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @Web @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code CDR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@Web @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Unpopulated Columns Into Aurora [Web Channel]
    When a "unpopulated columns CDR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-XLS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  #@Web @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Invalid Data Into Aurora [Web Channel]
    When a "invalid data CDR-XLS" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-XLS" file:
      | patient_nhs_number_valid_flag |


  @Web @FVE @HappyPath
  Scenario: Load valid CDR-FVE file to Aurora [Web Channel]
    When a "valid CDR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And I wait for the decryptor to process the file
    And the Glue job is triggered to process the "valid CDR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-FVE" file

  @Web @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with an Incorrect Lab Code Into Aurora [Web Channel]
    When a "incorrect lab code CDR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And I wait for the decryptor to process the file
    And the Glue job is triggered to process the "incorrect lab code CDR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
      | column_name | expected_value |
      | load_status | F              |

  @Web @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with Regex Errors Into Aurora [Web Channel]
    When a "regex error CDR-FVE" test file is uploaded to the "PreRegFileSrcWeb" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error CDR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table



  #SFTP==================================================================================================================================

  @SFTP @LIMS @HappyPath
  Scenario: Load valid CDR-LIMS file to Aurora [SFTP Channel]
    When a "valid CDR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid CDR-LIMS" file:
      | load_status |

  @SFTP @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error CDR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  #And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "regex error CDR-CSV" file:
  #| load_status  |

  @SFTP @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code CDR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @SFTP @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns CDR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-LIMS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @SFTP @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data CDR-LIMS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-LIMS" file:
      | patient_nhs_number_valid_flag |


  @SFTP @CSV @HappyPath
  Scenario: Load valid CDR-CSV file to Aurora [SFTP Channel]
    When a "valid CDR-CSV" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the records in "ods.specimen_request" table should match the source data in the "valid CDR-CSV" file

  @SFTP @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error CDR-CSV" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @SFTP @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code CDR-CSV" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @SFTP @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns CDR-CSV" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-CSV" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @SFTP @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data CDR-CSV" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-CSV" file:
      | patient_nhs_number_valid_flag |


  @SFTP @XLS @HappyPath
  Scenario: Load valid CDR-XLS file to Aurora [SFTP Channel]
    When a "valid CDR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-XLS" file

  @SFTP @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error CDR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "regex error CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @SFTP @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code CDR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@SFTP @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Unpopulated Columns Into Aurora [SFTP Channel]
    When a "unpopulated columns CDR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-XLS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  #@SFTP @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Invalid Data Into Aurora [SFTP Channel]
    When a "invalid data CDR-XLS" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-XLS" file:
      | patient_nhs_number_valid_flag |


  @SFTP @FVE @HappyPath
  Scenario: Load valid CDR-FVE file to Aurora [SFTP Channel]
    When a "valid CDR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And the Glue job is triggered to process the "valid CDR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-FVE" file

  @SFTP @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with an Incorrect Lab Code Into Aurora [SFTP Channel]
    When a "incorrect lab code CDR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
      | column_name | expected_value |
      | load_status | F              |

  @SFTP @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with Regex Errors Into Aurora [SFTP Channel]
    When a "regex error CDR-FVE" test file is uploaded to the "PreRegFileSrcSFTP" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error CDR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table



  #FileShare==================================================================================================================================

  @FS @LIMS @HappyPath
  Scenario: Load valid CDR-LIMS file to Aurora [FileShare Channel]
    When a "valid CDR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid CDR-LIMS" file:
      | load_status |

  @FS @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error CDR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "regex error CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  #And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "regex error CDR-CSV" file:
  #| load_status  |

  @FS @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code CDR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @FS @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns CDR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-LIMS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @FS @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data CDR-LIMS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-LIMS" file:
      | patient_nhs_number_valid_flag |


  @FS @CSV @HappyPath
  Scenario: Load valid CDR-CSV file to Aurora [FileShare Channel]
    When a "valid CDR-CSV" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the records in "ods.specimen_request" table should match the source data in the "valid CDR-CSV" file

  @FS @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error CDR-CSV" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "regex error CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @FS @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code CDR-CSV" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @FS @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns CDR-CSV" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-CSV" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @FS @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data CDR-CSV" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-CSV" file:
      | patient_nhs_number_valid_flag |


  @FS @XLS @HappyPath
  Scenario: Load valid CDR-XLS file to Aurora [FileShare Channel]
    When a "valid CDR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-XLS" file

  @FS @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error CDR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "regex error CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @FS @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code CDR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@FS @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Unpopulated Columns Into Aurora [FileShare Channel]
    When a "unpopulated columns CDR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-XLS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  #@FS @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Invalid Data Into Aurora [FileShare Channel]
    When a "invalid data CDR-XLS" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-XLS" file:
      | patient_nhs_number_valid_flag |


  @FS @FVE @HappyPath
  Scenario: Load valid CDR-FVE file to Aurora [FileShare Channel]
    When a "valid CDR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And the Glue job is triggered to process the "valid CDR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-FVE" file

  @FS @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with an Incorrect Lab Code Into Aurora [FileShare Channel]
    When a "incorrect lab code CDR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
      | column_name | expected_value |
      | load_status | F              |

  @FS @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with Regex Errors Into Aurora [FileShare Channel]
    When a "regex error CDR-FVE" test file is uploaded to the "PreRegFileSrcFileShare" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error CDR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table



  #Manual==================================================================================================================================

  @M @LIMS @HappyPath
  Scenario: Load valid CDR-LIMS file to Aurora [Manual Channel]
    When a "valid CDR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-LIMS" file
    And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid CDR-LIMS" file:
      | load_status |

  @M @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error CDR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "regex error CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"
  #And the following columns in the "ods.omd_file_log" table should have the value "F" for each record associated with the "regex error CDR-CSV" file:
  #| load_status  |

  @M @LIMS @WorkflowCheck
  Scenario: Load a CDR-LIMS file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code CDR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @M @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns CDR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-LIMS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @M @LIMS @DatabaseCheck
  Scenario: Load a CDR-LIMS file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data CDR-LIMS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-LIMS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-LIMS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-LIMS" file:
      | patient_nhs_number_valid_flag |


  @M @CSV @HappyPath
  Scenario: Load valid CDR-CSV file to Aurora [Manual Channel]
    When a "valid CDR-CSV" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the records in "ods.specimen_request" table should match the source data in the "valid CDR-CSV" file

  @M @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error CDR-CSV" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "regex error CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @M @CSV @WorkflowCheck
  Scenario: Load a CDR-CSV file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code CDR-CSV" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @M @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns CDR-CSV" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-CSV" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  @M @CSV @DatabaseCheck
  Scenario: Load a CDR-CSV file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data CDR-CSV" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-CSV" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-CSV" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-CSV" file:
      | patient_nhs_number_valid_flag |


  @M @XLS @HappyPath
  Scenario: Load valid CDR-XLS file to Aurora [Manual Channel]
    When a "valid CDR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-XLS" file

  @M @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error CDR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "regex error CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  @M @XLS @WorkflowCheck
  Scenario: Load a CDR-XLS file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code CDR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "incorrect lab code CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "FAILED"

  #@M @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Unpopulated Columns Into Aurora [Manual Channel]
    When a "unpopulated columns CDR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "unpopulated columns CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "unpopulated columns CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns CDR-XLS" file:
      | patient_nhs_number_pop_flag |
      | specimen_number_pop_flag    |
      | test_method_pop_flag        |
      | patient_postcode_pop_flag   |
      | specimen_type_pop_flag      |
      | organism_pop_flag           |

  #@M @XLS @DatabaseCheck
  Scenario: Load a CDR-XLS file with Invalid Data Into Aurora [Manual Channel]
    When a "invalid data CDR-XLS" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "invalid data CDR-XLS" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "invalid data CDR-XLS" file should be present in the file_name column of the "ods.omd_file_log" table
    And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "invalid data CDR-XLS" file:
      | patient_nhs_number_valid_flag |


  @M @FVE @HappyPath
  Scenario: Load valid CDR-FVE file to Aurora [Manual Channel]
    When a "valid CDR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And the Glue job is triggered to process the "valid CDR-FVE" file
    And I wait for the Glue job to complete
    Then the Glue job should complete with status "SUCCEEDED"
    And the "valid CDR-FVE" file should be present in the file_name column of the "ods.omd_file_log" table
  #And the records in "ods.specimen_request" table should match the source data in the "valid CDR-FVE" file

  @M @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with an Incorrect Lab Code Into Aurora [Manual Channel]
    When a "incorrect lab code CDR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And I wait for the decryptor to process the file
    Then the following columns in the most recent record of the "ods.omd_file_log" table should have the expected values:
      | column_name | expected_value |
      | load_status | F              |

  @M @FVE @WorkflowCheck
  Scenario: Load a CDR-FVE file with Regex Errors Into Aurora [Manual Channel]
    When a "regex error CDR-FVE" test file is uploaded to the "PreRegFileSrcManual" S3 folder
    And I wait for the decryptor to process the file
    Then the "regex error CDR-FVE" file should be absent in the file_name column of the "ods.omd_file_log" table