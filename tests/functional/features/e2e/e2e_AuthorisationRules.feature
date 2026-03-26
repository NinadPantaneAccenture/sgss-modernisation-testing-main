Feature: Managing Authorisation Rules via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Configuration" link in the navigation menu

    @Add @HappyPath
    Scenario: User attempts to add authorisation rules
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value     |
            | name  | TestAuth5 |
        And I click the "abiotrophia" button
        And I click the "adrenal" button
        And I click the "Save" button
        And the records shown should copy the "ods.cfg_auth_lab" table with "logical_delete_flag" of "0" and "lab_id" of "808"

    @View
    Scenario: User attempts to view authorisation rules
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And the records shown should copy the "ods.cfg_auth_lab" table with "logical_delete_flag" of "0" and "lab_id" of "808"


    @Add @UnhappyPath
    Scenario Outline: User attempts to add invalid authorisation rules - No name
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value  |
            | name  | <name> |
        And I click the "<organism>" button
        And I click the "<specimen_type>" button
        And I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | name | organism    | specimen_type | error_message |
            | BR01-51xx      |      | abiotrophia | adrenal       | Enter a name  |


    @Add @UnhappyPath
    Scenario Outline: User attempts to add invalid authorisation rules - No organism
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value    |
            | name  | TestAuth |
        And I click the "adrenal" button
        And I click the "Save" button
        Then I should see the following "error" message: "Select at least one organism"

    @Add @UnhappyPath
    Scenario: User attempts to add invalid authorisation rules - No specimen type
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value    |
            | name  | TestAuth |
        And I click the "abiotrophia" button
        And I click the "Save" button
        Then I should see the following "error" message: "Select at least one specimen type"

    @Edit @HappyPath
    Scenario: User attempts to edit authorisation rules
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field | Value     |
            | name  | TestAuth7 |
        And I click the "absidia" button
        And I click the "biofilm" button
        And I click the "Save" button
        And the records shown should copy the "ods.cfg_auth_lab" table with "logical_delete_flag" of "0" and "lab_id" of "808"


    Scenario: User attempts to delete authorisation rules
        And I click the "Authorisations" link in the navigation menu
        Then the page heading "Authorisations" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Delete [link]" button
        Then a confirmation dialog should appear
        And I click the "Delete [button]" button
        And the records shown should copy the "ods.cfg_auth_lab" table with "logical_delete_flag" of "0" and "lab_id" of "808"