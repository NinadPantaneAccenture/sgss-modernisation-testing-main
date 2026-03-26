Feature: Creating CDR Records via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Create CDR record" link in the navigation menu
        Then the page heading "Patient details" is displayed


    @FullForm @HappyPath
    Scenario: User attempts to create a new CDR record
        And I click the "New record" button
        And I fill in the form fields as follows
            | field                 | value                |
            | hospitalPatientNumber | 00123456             |
            | patientNhsNumber      | 1234567890           |
            | patientSurname        | EPCTEST              |
            | patientForename(s)    | EPCTEST              |
            | dateOfBirthDay        | 01                   |
            | dateOfBirthMonth      | 01                   |
            | dateOfBirthYear       | 1990                 |
            | addressLine1          | 30 Fenchurch Street, |
            | addressLine2          | London               |
            | addressLine3          | England              |
            | townOrCity            | Aldgate              |
            | county                | Bank                 |
            | postcode              | EC3M 5AD             |
            | occupation            | Software Tester      |
        And I select "OTHER / MIXED" from the "ethnicity" dropdown
        And I select "Male" from the "sex" dropdown
        Then I click the "Next" button
        Then the page heading "Specimen & Result" is displayed
        And I fill in the form fields as follows
            | field                        | value         |
            | specimenNumber               | SPEC002      |
            | specimenDateDay              | 01            |
            | specimenDateMonth            | 01            |
            | specimenDateYear             | 2023          |
            | laboratoryReportDateDay      | 01            |
            | laboratoryReportDateMonth    | 01            |
            | laboratoryReportDateYear     | 2023          |
            | laboratoryComments(optional) | Test Comments |
        And I select "ABDOMINAL FLUID" from the "specimenType" dropdown
        And I select "ANTIGEN DETECTIO" from the "testMethod" dropdown
        And I select "zTest" from the "reportingLaboratory" dropdown
        And I select "LEIFSONIA SP" from the "organism" dropdown
        And I click the "Add antimicrobial" button
        And I select "ABACAVIR" from the "antimicrobial" dropdown
        And I select "R" from the "sensitivityResult" dropdown
        And I click the "Add feature" button
        And I select "BLOOD DONOR" from the "feature" dropdown
        And I fill in the form fields as follows
            | field                     | value         |
            | reportDateDay             | 01            |
            | reportDateMonth           | 01            |
            | reportDateYear            | 2024          |
            | featureComments(optional) | Test Comments |
        Then I click the "Next" button
        Then the page heading "Additional information" is displayed
        And I fill in the form fields as follows
            | field        | value                |
            | addressLine1 | 30 Fenchurch Street, |
            | addressLine2 | London               |
            | addressLine3 | England              |
            | townOrCity   | Aldgate              |
            | county       | Bank                 |
            | postcode     | EC3M 5AD             |
        And I select "Yes" from the "travelAbroadIndicator" dropdown
        And I select "ALBANIA" from the "country" dropdown
        And I fill in the form fields as follows
            | field             | value                   |
            | travelInformation | Test travel information |
        And I select "Yes" from the "outbreakIndicator" dropdown
        And I fill in the form fields as follows
            | field               | value                     |
            | outbreakInformation | Test outbreak information |
        And I select "NOT VACCINATED" from the "vaccinationStatus" dropdown
        And I select "Yes" from the "patientDeathIndicator" dropdown
        And I select "Yes" from the "hospitalAcquiredIndicator" dropdown
        And I fill in the form fields as follows
            | field                 | value |
            | symptomOnsetDateDay   | 02    |
            | symptomOnsetDateMonth | 05    |
            | symptomOnsetDateYear  | 2024  |
        And I select "Yes" from the "immuno-compromisedIndicator" dropdown
        And I select "Yes" from the "asymptomaticIndicator" dropdown
        And I select "BONE AND JOINT" from the "bacteraemiaSource" dropdown
        Then I click the "Save" button
        #And I click the "Publish" button
        And the following columns in the most recent record of the "stg.stg2_specimen_request_test" table should have the expected values:
            | column_name     | expected_value   |
            | specimen_number | SPEC002 |


    @Page1 @Validations 
    Scenario: User attempts to create a new CDR record without the mandatory data on page 1
        And I fill in the form fields as follows
            | field                 | value |
            | hospitalPatientNumber |       |
            | patientNhsNumber      |       |
            | patientSurname        |       |
        Then I click the "Next" button
        Then I should see the following "error" message: "Enter at least an NHS number, hospital patient number or surname"


    @Page1 @Validations
    Scenario Outline: User attempts to create a new CDR record with invalid data on page 1
        And I fill in the form fields as follows
            | field   | value   |
            | <field> | <value> |
        Then I click the "Next" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | field              | value                                                                            | error_message                                   |
            | patientNhsNumber   | abcde                                                                            | NHS number must only contain digits             |
            | patientNhsNumber   | 1234                                                                             | NHS number must be 10 characters long           |
            | patientSurname     | JohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohnJohn | Patient surname must be 75 characters or fewer  |
            | patientForename(s) | SmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmithSmith | Patient forename must be 75 characters or fewer |
    # | hospitalPatientNumber | 12345 | Hospital patient number must be 255 characters or fewer |


    @Page1 @Validations
    Scenario: User attempts to create a new CDR record with invalid data on page 1 - ethnicity dropdown
        And I fill in the form fields as follows
            | field                 | value      |
            | hospitalPatientNumber | 1234       |
            | patientNhsNumber      | 1234567890 |
            | patientSurname        | Smith      |
        Then I click the "Next" button
        Then I should see the following "error" message: "Enter an ethnicity"

    @Page1 @Validations
    Scenario Outline: User attempts to create a new CDR record with invalid DOB on page 1
        And I fill in the form fields as follows
            | field   | value   |
            | <field> | <value> |
        Then I click the "Next" button
        Then I should see the following "error" message: "<error_message>"

        Examples:
            | field            | value | error_message                       |
            | patientNhsNumber | abcde | NHS number must only contain digits |





