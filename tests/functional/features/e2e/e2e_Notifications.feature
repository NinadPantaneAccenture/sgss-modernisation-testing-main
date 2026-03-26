Feature: Managing Notifications via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Configuration" link in the navigation menu
    
    
    @Add @HappyPath
    Scenario Outline: User attempts to add notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value            |
            | forename(s) | Test             |
            | surname     | User             |
            | email       | username@123.com |
        Then I click the "Save" button
        And the records shown should copy the "ods.cfg_email_phe" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | id |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | 1  |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | 2  |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | 4  |
            | BR01-51xx      | Alert                       | Alert email                          | 5  |
            | BR01-51xx      | Amended records             | Amended records email                | 6  |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | 8  |


    @Add @HappyPath @Dropdowns
    Scenario Outline: User attempts to add notification assignments for <notificationType> non-national notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value            |
            | forename(s) | Test             |
            | surname     | User             |
            | email       | username@123.com |
        Then I click the "Save" button
        And the records shown should copy the "<table_name>" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | table_name               | id |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | ods.cfg_email_lab        | 1  |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | ods.cfg_email_lab        | 7  |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | ods.cfg_email_phe_centre | 1  |

    @View
    Scenario Outline: User attempts to view notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And the records shown should copy the "ods.cfg_email_phe" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | id |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | 1  |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | 2  |
            | BR01-51xx      | DBS response                | DBS response email                   | 3  |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | 4  |
            | BR01-51xx      | Alert                       | Alert email                          | 5  |
            | BR01-51xx      | Amended records             | Amended records email                | 6  |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | 8  |



    @View @Dropdowns
    Scenario Outline: User attempts to view notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And the records shown should copy the "<table_name>" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | table_name               | id |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | ods.cfg_email_lab        | 1  |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | ods.cfg_email_lab        | 7  |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | ods.cfg_email_phe_centre | 1  |



    @Add @HappyPath
    Scenario Outline: User attempts to add notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value            |
            | forename(s) | Test             |
            | surname     | User             |
            | email       | username@123.com |
        Then I click the "Save" button
        And the records shown should copy the "ods.cfg_email_phe" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | id |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | 1  |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | 2  |
            | BR01-51xx      | DBS response                | DBS response email                   | 3  |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | 4  |
            | BR01-51xx      | Alert                       | Alert email                          | 5  |
            | BR01-51xx      | Amended records             | Amended records email                | 6  |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | 8  |


    @Add @HappyPath @Dropdowns
    Scenario Outline: User attempts to add notification assignments for <notificationType> non-national notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value            |
            | forename(s) | Test             |
            | surname     | User             |
            | email       | username@123.com |
        Then I click the "Save" button
        And the records shown should copy the "<table_name>" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | table_name               | id |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | ods.cfg_email_lab        | 1  |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | ods.cfg_email_lab        | 7  |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | ods.cfg_email_phe_centre | 1  |


    @Add @UnhappyPath @Invalid
    Scenario Outline: User attempts to add invalid notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        Then I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | FName_Value | SName_Value | email_Value      | error_message              |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS response                | DBS response email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Alert                       | Alert email                          |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Amended records             | Amended records email                |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | De-duplication log          | De-duplication log email             |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS response                | DBS response email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Alert                       | Alert email                          | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Amended records             | Amended records email                | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS response                | DBS response email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Alert                       | Alert email                          | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Amended records             | Amended records email                | test        | user        |                  | Enter an email             |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        | user        | abcde            | Email address is not valid |
            | BR01-51xx      | DBS response                | DBS response email                   | test        | user        | @abcde           | Email address is not valid |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        | user        | abcde            | Email address is not valid |
            | BR01-51xx      | Alert                       | Alert email                          | test        | user        | abcde@           | Email address is not valid |
            | BR01-51xx      | Amended records             | Amended records email                | test        | user        | 12345            | Email address is not valid |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        | user        | 2345             | Email address is not valid |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        | user        | qwerty           | Email address is not valid |


    @Add @UnhappyPath @Dropdowns @Invalid
    Scenario Outline: User attempts to add invalid notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        When I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | FName_Value | SName_Value | email_Value      | error_message              |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        | zxcvb.com        | Email address is not valid |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        | asdf@            | Email address is not valid |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        | qwert123         | Email address is not valid |


    @Add @UnhappyPath @Dropdowns @NoInstitution
    Scenario Outline: User attempts to add notification assignments for <notificationType> notifications without selecting a laboratory or PHE centre
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        When I click the "Save" button
        Then I should see the following "error" message: "One or more parameters are invalid"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | FName_Value | SName_Value | email_Value      |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        | username@123.com |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        | username@123.com |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        | username@123.com |



    @Edit @HappyPath
    Scenario Outline: User attempts to edit notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value             |
            | forename(s) | Tester            |
            | surname     | Userer            |
            | email       | username@1223.com |
        Then I click the "Save" button
        And the records shown should copy the "ods.cfg_email_phe" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | id |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | 1  |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | 2  |
            | BR01-51xx      | DBS response                | DBS response email                   | 3  |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | 4  |
            | BR01-51xx      | Alert                       | Alert email                          | 5  |
            | BR01-51xx      | Amended records             | Amended records email                | 6  |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | 8  |


    @Edit @HappyPath @Dropdowns
    Scenario Outline: User attempts to add notification assignments for <notificationType> non-national notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value             |
            | forename(s) | Tester            |
            | surname     | Userer            |
            | email       | username@1223.com |
        Then I click the "Save" button
        And the records shown should copy the "<table_name>" table with "email_type_id" of "<id>" and "logical_delete_flag" of "0"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | table_name               | id |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | ods.cfg_email_lab        | 1  |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | ods.cfg_email_lab        | 7  |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | ods.cfg_email_phe_centre | 1  |


    @Edit @UnhappyPath @Invalid
    Scenario Outline: User attempts to edit invalid notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        Then I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     | FName_Value | SName_Value | email_Value      | error_message              |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS response                | DBS response email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Alert                       | Alert email                          |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Amended records             | Amended records email                |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | De-duplication log          | De-duplication log email             |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS response                | DBS response email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Alert                       | Alert email                          | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Amended records             | Amended records email                | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS response                | DBS response email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Alert                       | Alert email                          | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Amended records             | Amended records email                | test        | user        |                  | Enter an email             |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        | user        |                  | Enter an email             |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   | test        | user        | abcde            | Email address is not valid |
            | BR01-51xx      | DBS response                | DBS response email                   | test        | user        | @abcde           | Email address is not valid |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             | test        | user        | abcde            | Email address is not valid |
            | BR01-51xx      | Alert                       | Alert email                          | test        | user        | abcde@           | Email address is not valid |
            | BR01-51xx      | Amended records             | Amended records email                | test        | user        | 12345            | Email address is not valid |
            | BR01-51xx      | De-duplication log          | De-duplication log email             | test        | user        | 2345             | Email address is not valid |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) | test        | user        | qwerty           | Email address is not valid |


    @Edit @UnhappyPath @Dropdowns @Invalid
    Scenario Outline: User attempts to edit invalid notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        When I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | FName_Value | SName_Value | email_Value      | error_message              |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   |             | user        | username@123.com | Enter a forename(s)        |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        |             | username@123.com | Enter a surname            |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        |                  | Enter an email             |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        | zxcvb.com        | Email address is not valid |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        | asdf@            | Email address is not valid |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        | qwert123         | Email address is not valid |


    @Edit @UnhappyPath @Dropdowns @NoInstitution
    Scenario Outline: User attempts to edit notification assignments for <notificationType> notifications without selecting a laboratory or PHE centre
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field       | Value         |
            | forename(s) | <FName_Value> |
            | surname     | <SName_Value> |
            | email       | <email_Value> |
        When I click the "Save" button
        Then I should see the following "error" message: "One or more parameters are invalid"

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                | FName_Value | SName_Value | email_Value      |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) | test        | user        | username@123.com |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       | test        | user        | username@123.com |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   | test        | user        | username@123.com |



    @Delete
    Scenario Outline: User attempts to delete notification assignments for <notificationType> notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        Then the table should be loaded with records
        And I click the "Delete [link]" button
        Then a confirmation dialog should appear
        Then I click the "Delete [button]" button

        Examples:
            | Jira Issue Key | notificationType            | expected_heading                     |
            | BR01-51xx      | DBS outgoing                | DBS outgoing email                   |
            | BR01-51xx      | DBS response                | DBS response email                   |
            | BR01-51xx      | DBS return timeout          | DBS return timeout email             |
            | BR01-51xx      | Alert                       | Alert email                          |
            | BR01-51xx      | Amended records             | Amended records email                |
            | BR01-51xx      | De-duplication log          | De-duplication log email             |
            | BR01-51xx      | Daily status update [first] | Daily status update email (national) |


    @Delete @Dropdowns
    Scenario Outline: User attempts to add notification assignments for <notificationType> non-national notifications
        And I click the "Notifications" link in the navigation menu
        Then the page heading "Daily status update email (national)" is displayed
        And I click the "<notificationType>" button
        Then the page heading "<expected_heading>" is displayed
        And I select "<institution>" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Delete [link]" button
        Then a confirmation dialog should appear
        Then I click the "Delete [button]" button

        Examples:
            | Jira Issue Key | notificationType            | institution      | expected_heading                                |
            | BR01-51xx      | Daily status update [third] | zTest            | Daily status update (lab)                       |
            | BR01-51xx      | Skipped sequence number     | zTest            | Skipped sequence number email                   |
            | BR01-51xx      | Daily status update [local] | Anglia and Essex | Daily status update email (local/regional area) |
