Feature: Uploading Test Record Files via Web Portal

    Background: 
        Given I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed

    # Scenario: User uploads a valid CDR file through the web portal
    #     And I select a "valid CDR-CSV" file to upload
    #     And I click the "Submit" button
    #     Then I should see the following "success" message: "File uploaded successfully!"

    Scenario: User uploads an empty CDR file through the web portal
        And I select an "empty cdr" file to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because the file is empty"
    
    Scenario: User uploads an oversized CDR file through the web portal
        And I select an "oversized cdr file" to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because the file is too large"
    
    Scenario: User attempts to upload without selecting a file
        But the "Submit" button is disabled
    
    Scenario: User uploads a CDR file in an unaccepted file type
        And I select an "invalid file type" to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because the file is not a recognised type"

    Scenario: User uploads a CDR file with incorrect lab codes
        And I select an "incorrect lab codes file" to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because the lab code is not valid"
    
    Scenario: User uploads a CDR file with unauthorised lab codes
        And I select an "unauthorised lab codes file" to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because it is not for one of your labs"

    Scenario: User uploads a previously uploaded file
        And I select a "valid cdr file" to upload
        And I click the "Submit" button
        Then I should see the following "error" message: "The file upload failed because file zxgcdr2013052015302500000081.txt has already been uploaded"