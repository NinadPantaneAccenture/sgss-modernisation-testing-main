Feature: Uploading Test Record Files to SGSS

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed

    @HappyPath
    Scenario Outline: User uploads a valid <filename> file through the web portal
        And I select a "valid <filename>" file to upload via the web UI
        And I click the "Submit" button
        Then I should see the following "success" message: "File uploaded successfully!"
        And I should see the uploaded file in the "PreRegFileSrcWeb" S3 folder
        Then the Glue job is triggered to process the "valid <filename>" file
        And I wait for the Glue job to complete
        Then the Glue job should complete with status "SUCCEEDED"
        And the "valid <filename>" file should be present in the file_name column of the "ods.omd_file_log" table
        And the following columns in the "ods.omd_file_log" table should have the value "L" for each record associated with the "valid <filename>" file:
            | column_name |
            | load_status |

        Examples:
            | Jira Issue Key | filename |
            | BR01-5168      | CDR-LIMS |
            | BR01-5081      | CDR-CSV  |
            | BR01-5163      | CDR-XLS  |
            | BR01-5164      | CDR-FVE  |
            | BR01-5165      | AMR-LIMS |
            | BR01-5166      | AMR-XLS  |
            | BR01-5167      | AMR-FVE  |


    @WebValidations
    Scenario Outline: User uploads an <filename> file through the web portal
        And I select an "<filename>" file to upload via the web UI
        And I click the "Submit" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | filename              | error_message                                                    |
            | BR01-5083      | empty cdr             | The selected file is empty                                       |
            | BR01-5169      | oversized cdr         | The selected file must be smaller than 50MB                      |
            | BR01-5170      | invalid file type     | The file upload failed because the file is not a recognised type |
            | BR01-5171      | incorrect lab code    | The file upload failed because the lab code is not valid         |
            | BR01-5172      | unauthorised lab code | The file upload failed because it is not for one of your labs    |


    @RecordLevelValidations @PopFlag
    Scenario Outline: User uploads a <filename> file with Unpopulated Columns through the web portal
        And I select a "unpopulated columns <filename>" file to upload via the web UI
        And I click the "Submit" button
        Then I should see the following "success" message: "File uploaded successfully!"
        And I should see the uploaded file in the "PreRegFileSrcWeb" S3 folder
        And the Glue job is triggered to process the "unpopulated columns <filename>" file
        And I wait for the Glue job to complete
        Then the Glue job should complete with status "SUCCEEDED"
        And the "unpopulated columns <filename>" file should be present in the file_name column of the "ods.omd_file_log" table
        And the following columns in the "ods.specimen_request" table should have the value "1" for each record associated with the "unpopulated columns <filename>" file:
            | patient_forename_pop_flag     |
            | patient_surname_pop_flag      |
            | patient_nhs_number_pop_flag   |
            | patient_dob_pop_flag          |
            | patient_postcode_pop_flag     |
            | specimen_number_pop_flag      |
            | test_method_pop_flag          |
            | rqsting_organisation_pop_flag |
            | specimen_type_pop_flag        |
            | organism_pop_flag             |

        Examples:
            | Jira Issue Key | filename |
            | BR01-5547      | CDR-LIMS |
            | BR01-5548      | CDR-CSV  |
            # | BR01-5549      | CDR-XLS  |
            #| BR01-5550      | CDR-FVE  |
            | BR01-5551      | AMR-LIMS |
    ##| BR01-5552      | AMR-XLS  |
    #| BR01-5553      | AMR-FVE  |


    @RecordLevelValidations @ValidFlag
    Scenario Outline: User uploads a <filename> file with Invalid Data through the web portal
        And I select a "invalid data <filename>" file to upload via the web UI
        And I click the "Submit" button
        Then I should see the following "success" message: "File uploaded successfully!"
        And I should see the uploaded file in the "PreRegFileSrcWeb" S3 folder
        And the Glue job is triggered to process the "invalid data <filename>" file
        And I wait for the Glue job to complete
        Then the Glue job should complete with status "SUCCEEDED"
        And the "invalid data <filename>" file should be present in the file_name column of the "ods.omd_file_log" table
        And the following columns in the "ods.specimen_request" table should have the value "-1" for each record associated with the "invalid data <filename>" file:
            | patient_nhs_number_valid_flag       |
            | patient_dob_valid_flag              |
            | patient_age_years_valid_flag        |
            | lab_report_date_valid_flag          |
            | specimen_request_test_valid_flag    |
            | hospital_patient_no_valid_flag      |
            | patient_surname_valid_flag          |
            | specimen_request_feature_valid_flag |
            | symptom_onset_date_valid_flag       |

        Examples:
            | Jira Issue Key | filename |
            | BR01-5554      | CDR-LIMS |
            | BR01-5555      | CDR-CSV  |
            #| BR01-5556      | CDR-XLS  |
            # | BR01-5557      | CDR-FVE  |
            | BR01-5558      | AMR-LIMS |
## | BR01-5559      | AMR-XLS  |
#| BR01-5560      | AMR-FVE  |