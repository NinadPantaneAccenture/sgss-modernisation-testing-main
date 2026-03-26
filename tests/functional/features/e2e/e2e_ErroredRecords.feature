Feature: Managing Errored Files in the SGSS Web Portal

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR Files" is displayed

    @View
    Scenario Outline: User attempts to view erroring records
        And I click the "<filetype>" link in the navigation menu
        Then the page heading "<page_heading>" is displayed
        #And the "<tab_name>" tab table data should be loaded with records
        And the records shown in the "<tab_name>" tab should match the records in the "<database_table>" table with "load_status" of "<status>"

        Examples:
            | Jira Issue Key | filetype   | page_heading | database_table                | tab_name           | status      |
            | BR01-5085      | Failed CDR | CDR Records  | ods.specimen_request          | Failed Validation  | NOT_VALID   |
            | BR01-5086      | Failed AMR | AMR Records  | ods.specimen_request_susc_amr | Failed Validation  | NOT_VALID   |
            | BR01-5087      | Failed CDR | CDR Records  | ods.specimen_request          | Failed Translation | TRANS_ERROR |
            | BR01-5181      | Failed AMR | AMR Records  | ods.specimen_request_susc_amr | Failed Translation | TRANS_ERROR |
            | BR01-5184      | Failed CDR | CDR Records  | ods.specimen_request          | Authorisation      | NOT_AUTH    |


    @DeleteErrors
    Scenario Outline: User attempts to delete erroring records
        And I click the "<filetype>" link in the navigation menu
        Then the page heading "<page_heading>" is displayed
        #And the "<tab_name>" tab table data should be loaded with records
        And I enable the first checkbox in the table
        And I click the "Delete" button
        Then a confirmation dialog should appear
        When I click the "Delete [errors]" button
        Then the record should be removed from the "<tab_name>" tab table
        And the records shown in the "<tab_name>" tab should match the records in the "<database_table>" table with "load_status" of "<status>"

        Examples:
            | Jira Issue Key | filetype   | page_heading | database_table                | tab_name           | status      |
            | BR01-5175      | Failed CDR | CDR Records  | ods.specimen_request          | Failed Validation  | NOT_VALID   |
            | BR01-5177      | Failed AMR | AMR Records  | ods.specimen_request_susc_amr | Failed Validation  | NOT_VALID   |
            | BR01-5179      | Failed CDR | CDR Records  | ods.specimen_request          | Failed Translation | TRANS_ERROR |
            | BR01-5182      | Failed AMR | AMR Records  | ods.specimen_request_susc_amr | Failed Translation | TRANS_ERROR |
            | BR01-5186      | Failed CDR | CDR Records  | ods.specimen_request          | Authorisation      | NOT_AUTH    |


    @BR01-5187 @AuthoriseErrors
    Scenario: User attempts to authorise erroring records
        And I click the "Failed CDR" link in the navigation menu
        Then the page heading "CDR Records" is displayed
        #And the "Authorisation" tab table data should be loaded with records
        And I enable the first checkbox
        And I click the "Authorise" button
        Then a confirmation dialog should appear
        When I click the "Authorise" button on the dialog box
        Then the record should be removed from the "Authorisation" tab table
        And the records shown in the "Authorisation" tab should match the records in the "ods.specimen_request" table with "load_status" of "NOT_AUTH"

@EditErrors**
# Scenario Outline: User attempts to edit erroring records
# And I click the "<filetype>" link in the navigation menu
#     Then the page heading "<page_heading>" is displayed
#     And the "<tab_name>" tab table data should be loaded with records
#     And I select a record in the "<tab_name>" tab table
#     And I click the "Edit" button
#     Then a confirmation dialog should appear
#     When I click the "Edit" button on the dialog box
#     #And I fill in the form fields as follows
#          | Field Name  | Value  |
#         | field_name_1 | value_1 |
#         | field_name_2 | value_2 |
#         | field_name_3 | value_3 |
#     #And I click the "Submit" button on the edit form
#     Then the record should be removed the "<tab_name>" tab table
#     #And the records shown in the "<tab_name>" tab should match the records in the "ods.specimen_request" table with "load_status" of "AWAIT_INGEST"

#     Examples:
#         | Jira Issue Key | filetype   | page_heading | tab_name             |
#         | BR01-5176      | Failed CDR | CDR Records  | Failed Validation    |
#         | BR01-5178      | Failed AMR | AMR Records  | Failed Validation    |
#         | BR01-5180      | Failed CDR | CDR Records  | Failed Translation   |
#         | BR01-5183      | Failed AMR | AMR Records  | Failed Translation   |
#         | BR01-5185      | Failed CDR | CDR Records  | Authorisation |