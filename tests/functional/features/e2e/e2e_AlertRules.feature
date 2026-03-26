Feature: Managing Alert Rules via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Configuration" link in the navigation menu
    
    @E2E @Add @HappyPath @TEMPTEST
    Scenario: User attempts to add alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value     |
            | name  | TestAlert96 |
        And I click the "abiotrophia" button
        And I click the "adrenal" button
        And I click the "Save" button
        And the records shown in the table should match the records in the "ods.cfg_alert" table with "logical_delete_flag" of "0"

    @E2E @View
    Scenario: User attempts to view alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And the records shown in the table should match the records in the "ods.cfg_alert" table with "logical_delete_flag" of "0"

    @E2E @Add @UnhappyPath
    Scenario: User attempts to add empty name alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value |
            | name  |       |
        And I click the "Abiotrophia" button
        And I click the "Adrenal" button
        And I click the "Save" button
        Then I should see the following "error" message: "Enter a name"

    @E2E @Add @UnhappyPath
    Scenario: User attempts to add empty organism alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value     |
            | name  | TestAlert |
        And I click the "Adrenal" button
        And I click the "Save" button
        Then I should see the following "error" message: " Select at least one organism"

    @E2E @Add @UnhappyPath
    Scenario: User attempts to add empty specimen alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value     |
            | name  | TestAlert |
        And I click the "Abiotrophia" button
        And I click the "Save" button
        Then I should see the following "error" message: "Select at least one specimen type"


    @E2E @Edit @HappyPath
    Scenario: User attempts to edit alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value      |
            | name  | TestAlert2 |
        And I click the "Absidia" button
        And I click the "Aspiration" button
        And I click the "Save" button
        And the records shown in the table should match the records in the "ods.cfg_alert" table with "logical_delete_flag" of "0"

    @E2E @Delete
    Scenario: User attempts to delete alert rules
        And I click the "Alerts" link in the navigation menu
        Then the page heading "Alerts" is displayed
        Then the table should be loaded with records
        And I click the "Delete [link]" button
        Then a confirmation dialog should appear
        When I click the "Delete [button]" button
        And the records shown in the table should match the records in the "ods.cfg_alert" table with "logical_delete_flag" of "0"
