Feature: Searching for Records in the SGSS Web Portal

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR Files" is displayed

    Scenario: User attempts to view search results summary
        And I click the "Search CDR" link in the navigation menu
        Then the page heading "Search CDR Records" is displayed
        And I fill in the form fields as follows
            | field           | value   |
            # | fromDay                 | value   |
            # | fromMonth               | value   |
            # | fromYear                | value   |
            # | toDay                   | value   |
            # | toMonth                 | value   |
            # | toYear                  | value   |
            # | specimenNumber          | value   |
            # | organism                | value   |
            # | patientSurname          | value   |
            # | hospitalPatientNumber   | value   |
            | patientForename | EPCTEST |
        # | nhsNumber               | value   |
        # | postcode                | value   |
        # | specimenRequestId       | value   |
        # | patientDateOfBirthDay   | value   |
        # | patientDateOfBirthMonth | value   |
        # | patientDateOfBirthYear  | value   |
        And I click the "Search" button
        Then the table should be loaded with records
        And the records shown in the table should match the records in the "ods.specimen_request" table with "patient_forename" of "EPCTEST"
    #Then the search results table should be loaded with records matching the the equivalent query in the "ods.specimen_request" table

    Scenario: User attempts to delete records from search results summary
        And I click the "Search CDR" link in the navigation menu
        Then the page heading "Search CDR Records" is displayed
        And I fill in the form fields as follows
            | field           | value   |
            # | fromDay                 | value   |
            # | fromMonth               | value   |
            # | fromYear                | value   |
            # | toDay                   | value   |
            # | toMonth                 | value   |
            # | toYear                  | value   |
            # | specimenNumber          | value   |
            # | organism                | value   |
            # | patientSurname          | value   |
            # | hospitalPatientNumber   | value   |
            | patientForename | EPCTEST |
        # | nhsNumber               | value   |
        # | postcode                | value   |
        # | specimenRequestId       | value   |
        # | patientDateOfBirthDay   | value   |
        # | patientDateOfBirthMonth | value   |
        # | patientDateOfBirthYear  | value   |
        And I click the "Search" button
        Then the table should be loaded with records
        And I enable the first checkbox
        And I click the "Delete [button]" button
        Then a confirmation dialog should appear
        When I click the "Delete" button on the dialog box
    #Then the record should be removed from the table
    #Then the search results table should be loaded with records matching the the equivalent query in the "ods.specimen_request" table

    Scenario: User attempts to merge records from search results summary
        And I click the "Search CDR" link in the navigation menu
        Then the page heading "Search CDR Records" is displayed
        And I fill in the form fields as follows
            | field           | value   |
            # | fromDay                 | value   |
            # | fromMonth               | value   |
            # | fromYear                | value   |
            # | toDay                   | value   |
            # | toMonth                 | value   |
            # | toYear                  | value   |
            # | specimenNumber          | value   |
            # | organism                | value   |
            # | patientSurname          | value   |
            # | hospitalPatientNumber   | value   |
            | patientForename | EPCTEST |
        # | nhsNumber               | value   |
        # | postcode                | value   |
        # | specimenRequestId       | value   |
        # | patientDateOfBirthDay   | value   |
        # | patientDateOfBirthMonth | value   |
        # | patientDateOfBirthYear  | value   |
        And I click the "Search" button
        Then the table should be loaded with records
        And I enable the first two checkboxes
        #And I enable the second checkbox
        And I click the "Merge" button
        Then a confirmation dialog should appear
        When I click the "Merge" button on the dialog box
#Then the merged records should be removed from the table
#Then the search results table should be loaded with records matching the the equivalent query in the "ods.specimen_request" table