Feature: Failed AMR Page

    Background: 
        Given I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "Upload AMR or CDR File" is displayed
        And I click the "Failed AMR" link in the navigation menu
        Then the page heading "AMR Records" is displayed

#Failed Validations ----------------------------------------------------------------------

    Scenario: View AMR records with failed validations
        And the "Failed Validation" tab table data should be loaded with records

    Scenario: Delete AMR records with failed validations
        When the "Failed Validation" tab table data is loaded with records
        And I click the checkbox for the first record in the "Failed Validation" tab
        And I click the "Delete" button
        Then a confirmation dialog should appear
        When I click the "Delete" button on the dialog box
        Then the record should be removed from the "Failed Validation" tab table