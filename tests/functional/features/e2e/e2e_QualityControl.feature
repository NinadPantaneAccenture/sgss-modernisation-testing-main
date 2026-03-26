Feature: Managing Quality Control Rules via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Configuration" link in the navigation menu

    @BR01-5332 @Add @HappyPath
    Scenario: User attempts to add quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field                 | Value      |
            | nhsNumber             | 1234567890 |
            | hospitalPatientNumber | 12345      |
            | surname               | QualCon    |
            | dateOfBirthDay        | 30         |
            | dateOfBirthMonth      | 4          |
            | dateOfBirthYear       | 1990       |
        And I click the "Save" button
        And the records shown in the table should match the records in the "ods.cfg_quality_control" table with "logical_delete_flag" of "0"

    @Add @UnhappyPath
    Scenario Outline: User attempts to add invalid quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Add" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field                 | Value                   |
            | nhsNumber             | <nhsNumber>             |
            | hospitalPatientNumber | <hospitalPatientNumber> |
            | surname               | <surname>               |
            | dateOfBirthDay        | <dateOfBirthDay>        |
            | dateOfBirthMonth      | <dateOfBirthMonth>      |
            | dateOfBirthYear       | <dateOfBirthYear>       |
        And I click the "Save" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | Jira Issue Key | nhsNumber  | hospitalPatientNumber | surname  | dateOfBirthDay | dateOfBirthMonth | dateOfBirthYear | error_message                                                    |
            | BR01-51xx      | abcde      | 12345                 | QualCon  | 30             | 4                | 1990            | NHS number must only contain digits                              |
            | BR01-51xx      | 1234567890 | 12345                 | QualCon2 | 100            | 88               | 1990            | Date of birth is not valid                                       |
            | BR01-51xx      |            |                       |          | 28             | 4                | 1990            | Enter at least an NHS number, hospital patient number or surname |

    @BR01-5331
    Scenario: User attempts to view quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records

    @Edit @HappyPath
    Scenario: User attempts to edit quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field                 | Value      |
            | nhsNumber             | 2234567890 |
            | hospitalPatientNumber | 22345      |
            | surname               | QualCtrl   |
            | dateOfBirthDay        | 31         |
            | dateOfBirthMonth      | 5          |
            | dateOfBirthYear       | 1991       |
        And I click the "Save" button
        And the records shown in the table should match the records in the "ods.cfg_quality_control" table with "logical_delete_flag" of "0"


    @Edit @UnhappyPath
    Scenario Outline: User attempts to edit invalid quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Edit" button
        Then a confirmation dialog should appear
        And I fill in the form fields as follows
            | Field                 | Value                   |
            | nhsNumber             | <nhsNumber>             |
            | hospitalPatientNumber | <hospitalPatientNumber> |
            | surname               | <surname>               |
            | dateOfBirthDay        | <dateOfBirthDay>        |
            | dateOfBirthMonth      | <dateOfBirthMonth>      |
            | dateOfBirthYear       | <dateOfBirthYear>       |
        And I click the "Save" button
        Then I should see the following "error" message: "<error_message>"
        Examples:
            | Jira Issue Key | nhsNumber  | hospitalPatientNumber | surname  | dateOfBirthDay | dateOfBirthMonth | dateOfBirthYear | error_message                                                    |
            | BR01-51xx      | abcde      | 12345                 | QualCon  | 30             | 4                | 1990            | NHS number must only contain digits                              |
            | BR01-51xx      | 1234567890 | 12345                 | QualCon2 | 2              | 99               | 1990            | Date of birth is not valid                                       |
            | BR01-51xx      |            |                       |          | 28             | 4                | 1990            | Enter at least an NHS number, hospital patient number or surname |

    Scenario: User attempts to delete quality control rules
        And I click the "Quality control" link in the navigation menu
        Then the page heading "Quality control" is displayed
        And I select "zTest" from the "filterBy" dropdown
        Then the table should be loaded with records
        And I click the "Delete [link]" button
        Then a confirmation dialog should appear
        And I click the "Delete [button]" button
        And the records shown in the table should match the records in the "ods.cfg_quality_control" table with "logical_delete_flag" of "0"
