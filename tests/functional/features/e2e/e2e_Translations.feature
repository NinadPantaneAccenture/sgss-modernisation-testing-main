Feature: Managing translations via the web ui

    Background:
        Given the test environment is configured
        And I have navigated to the landing page
        When I log in via Entra ID
        Then the page heading "AMR and CDR files" is displayed
        And I click the "Configuration" link in the navigation menu
        And I click the "Translations" link in the navigation menu
        Then the page heading "Translations" is displayed

    @Add @HappyPath
    Scenario Outline: User attempts to add lab translations for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I select "<systemCodeDescription>" from the "systemCodeDescription" dropdown
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"

        Examples:
            | Jira Issue Key | entity_type                  | systemCodeDescription | entity_type_id |
            | BR01-522X      | Antimicrobial                | AMPICILLIN            | 1              |
            | BR01-522X      | Bacteraemia Source           | BONE AND JOINT        | 2              |
            | BR01-522X      | Ethnicity Type               | BLACK - AFRICA        | 3              |
            | BR01-522X      | Feature                      | ANAEMIA               | 4              |
            | BR01-522X      | Medical Specialty            | CARDIOLOGY            | 9              |
            | BR01-522X      | Molecular Type               | GENOTYPE 3            | 10             |
            | BR01-522X      | Organism                     | ABSIDIA SP            | 11             |
            | BR01-522X      | Other Type                   | ND                    | 12             |
            | BR01-522X      | Phage Type                   | COLINDALE             | 13             |
            | BR01-522X      | Requesting Organisation Type | ARMED FORCES          | 14             |
            | BR01-522X      | Sensitivity Result           | Q                     | 15             |
            | BR01-522X      | Sero Type                    | 11                    | 16             |
            | BR01-522X      | Specimen Type                | APPENDIX              | 17             |
            | BR01-522X      | Test Method                  | CULTURE               | 18             |
            | BR01-522X      | Toxin                        | TOXIN A               | 19             |
            | BR01-522X      | Vaccination Status           | NOT VACCINATED        | 20             |

    @Add @HappyPath
    Scenario Outline: User attempts to add lab translations for <entity_type> - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I type "<systemCodeDescription>" into the autocomplete field and select the result
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"

        Examples:
            | Jira Issue Key | entity_type             | systemCodeDescription | entity_type_id |
            | BR01-123X      | Hospital Consultant     | AAZE                  | 7              |
            | BR01-123X      | Laboratory              | CONCEPTO              | 8              |
            | BR01-123X      | Requesting Organisation | XOG                   | 6              |
    @Add @HappyPath
    Scenario: User attempts to add lab translations for GP - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "GP" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I type "BALMOR" into the autocomplete field and select the result
        And I select "AHMAD J, BALMORAL GARDENS" from the "gp" dropdown
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "5"
    #-==============================================================>

    @Add @UnhappyPath @EmptyCode
    Scenario Outline: User attempts to add empty LIMS Laboratory Code for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value |
            | limsLaboratoryCode |       |
        And I select "<systemCodeDescription>" from the "systemCodeDescription" dropdown
        And I click the "Save" button
        Then I should see the following "error" message: "Enter a LIMS laboratory code"

        Examples:
            | Jira Issue Key | entity_type                  | systemCodeDescription |
            | BR01-522X      | Antimicrobial                | AMPICILLIN            |
            | BR01-522X      | Bacteraemia Source           | BONE AND JOINT        |
            | BR01-522X      | Ethnicity Type               | BLACK - AFRICA        |
            | BR01-522X      | Feature                      | ANAEMIA               |
            | BR01-522X      | Medical Specialty            | CARDIOLOGY            |
            | BR01-522X      | Molecular Type               | GENOTYPE 3            |
            | BR01-522X      | Organism                     | ABSIDIA SP            |
            | BR01-522X      | Other Type                   | ND                    |
            | BR01-522X      | Phage Type                   | COLINDALE             |
            | BR01-522X      | Requesting Organisation Type | ARMED FORCES          |
            | BR01-522X      | Sensitivity Result           | Q                     |
            | BR01-522X      | Sero Type                    | 11                    |
            | BR01-522X      | Specimen Type                | APPENDIX              |
            | BR01-522X      | Test Method                  | CULTURE               |
            | BR01-522X      | Toxin                        | TOXIN A               |
            | BR01-522X      | Vaccination Status           | NOT VACCINATED        |


    @Add @UnhappyPath @EmptyCode
    Scenario Outline: User attempts to add empty LIMS Laboratory Code for <entity_type> - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value |
            | limsLaboratoryCode |       |
        And I type "<systemCodeDescription>" into the autocomplete field and select the result
        And I click the "Save" button
        Then I should see the following "error" message: "Enter a LIMS laboratory code"

        Examples:
            | Jira Issue Key | entity_type             | systemCodeDescription | entity_type_id |
            | BR01-123X      | Hospital Consultant     | AAZE                  | 7              |
            | BR01-123X      | Laboratory              | CONCEPTO              | 8              |
            | BR01-123X      | Requesting Organisation | XOG                   | 6              |


    @Add @UnhappyPath @EmptyCode
    Scenario: User attempts to add lab translations for GP - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "GP" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value |
            | limsLaboratoryCode |       |
        And I type "BALMOR" into the autocomplete field and select the result
        And I select "AHMAD J, BALMORAL GARDENS" from the "gp" dropdown
        And I click the "Save" button
        Then I should see the following "error" message: "Enter a LIMS laboratory code"


    @Add @UnhappyPath @CharacterLimit
    Scenario Outline: User attempts to add LIMS Laboratory Code with too many characters for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value      |
            | limsLaboratoryCode | <RANDOM55> |
        And I select "<systemCodeDescription>" from the "systemCodeDescription" dropdown
        And I click the "Save" button
        Then I should see the following "error" message: "LIMS laboratory code must be 50 characters or fewer"

        Examples:
            | Jira Issue Key | entity_type                  | systemCodeDescription |
            | BR01-522X      | Antimicrobial                | AMPICILLIN            |
            | BR01-522X      | Bacteraemia Source           | BONE AND JOINT        |
            | BR01-522X      | Ethnicity Type               | BLACK - AFRICA        |
            | BR01-522X      | Feature                      | ANAEMIA               |
            | BR01-522X      | Medical Specialty            | CARDIOLOGY            |
            | BR01-522X      | Molecular Type               | GENOTYPE 3            |
            | BR01-522X      | Organism                     | ABSIDIA SP            |
            | BR01-522X      | Other Type                   | ND                    |
            | BR01-522X      | Phage Type                   | COLINDALE             |
            | BR01-522X      | Requesting Organisation Type | ARMED FORCES          |
            | BR01-522X      | Sensitivity Result           | Q                     |
            | BR01-522X      | Sero Type                    | 11                    |
            | BR01-522X      | Specimen Type                | APPENDIX              |
            | BR01-522X      | Test Method                  | CULTURE               |
            | BR01-522X      | Toxin                        | TOXIN A               |
            | BR01-522X      | Vaccination Status           | NOT VACCINATED        |


    @Add @UnhappyPath @CharacterLimit
    Scenario Outline: User attempts to add LIMS Laboratory Code with too many characters for <entity_type> - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value      |
            | limsLaboratoryCode | <RANDOM55> |
        And I type "<systemCodeDescription>" into the autocomplete field and select the result
        And I click the "Save" button
        Then I should see the following "error" message: "LIMS laboratory code must be 50 characters or fewer"

        Examples:
            | Jira Issue Key | entity_type             | systemCodeDescription | entity_type_id |
            | BR01-123X      | Hospital Consultant     | AAZE                  | 7              |
            | BR01-123X      | Laboratory              | CONCEPTO              | 8              |
            | BR01-123X      | Requesting Organisation | XOG                   | 6              |


    @Add @UnhappyPath @CharacterLimit
    Scenario: User attempts to add LIMS Laboratory Code with too many characters for GP - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "GP" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value      |
            | limsLaboratoryCode | <RANDOM55> |
        And I type "BALMOR" into the autocomplete field and select the result
        And I select "AHMAD J, BALMORAL GARDENS" from the "gp" dropdown
        And I click the "Save" button
        Then I should see the following "error" message: "LIMS laboratory code must be 50 characters or fewer"


    @View
    Scenario Outline: User attempts to view lab translations for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"

        Examples:
            | Jira Issue Key | entity_type                  | entity_type_id |
            | BR01-522X      | Antimicrobial                | 1              |
            | BR01-522X      | Bacteraemia Source           | 2              |
            | BR01-522X      | Ethnicity Type               | 3              |
            | BR01-522X      | Feature                      | 4              |
            | BR01-522X      | Medical Specialty            | 9              |
            | BR01-522X      | Molecular Type               | 10             |
            | BR01-522X      | Organism                     | 11             |
            | BR01-522X      | Other Type                   | 12             |
            | BR01-522X      | Phage Type                   | 13             |
            | BR01-522X      | Requesting Organisation Type | 14             |
            | BR01-522X      | Sensitivity Result           | 15             |
            | BR01-522X      | Sero Type                    | 16             |
            | BR01-522X      | Specimen Type                | 17             |
            | BR01-522X      | Test Method                  | 18             |
            | BR01-522X      | Toxin                        | 19             |
            | BR01-522X      | Vaccination Status           | 20             |
            | BR01-522X      | GP                           | 5              |
            | BR01-522X      | Hospital Consultant          | 7              |
            | BR01-522X      | Laboratory                   | 8              |
            | BR01-522X      | Requesting Organisation      | 6              |

    @Edit @HappyPath
    Scenario Outline: User attempts to edit lab translations for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Edit" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I select "<systemCodeDescription>" from the "systemCodeDescription" dropdown
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"

        Examples:
            | Jira Issue Key | entity_type                  | systemCodeDescription  | entity_type_id |
            | BR01-522X      | Antimicrobial                | ABACAVIR               | 1              |
            | BR01-522X      | Bacteraemia Source           | CENTRAL NERVOUS SYSTEM | 2              |
            | BR01-522X      | Ethnicity Type               | WHITE BRITISH          | 3              |
            | BR01-522X      | Feature                      | BRONCHITIS             | 4              |
            | BR01-522X      | Medical Specialty            | DIABETIC MEDICINE      | 9              |
            | BR01-522X      | Molecular Type               | NCOV                   | 10             |
            | BR01-522X      | Organism                     | ADENOVIRUS             | 11             |
            | BR01-522X      | Other Type                   | 22                     | 12             |
            | BR01-522X      | Phage Type                   | DT 100                 | 13             |
            | BR01-522X      | Requesting Organisation Type | COMMUNITY SERVICE      | 14             |
            | BR01-522X      | Sensitivity Result           | U                      | 15             |
            | BR01-522X      | Sero Type                    | 24F                    | 16             |
            | BR01-522X      | Specimen Type                | LUNG                   | 17             |
            | BR01-522X      | Test Method                  | SEQUENCING             | 18             |
            | BR01-522X      | Toxin                        | NON-TOXIGENIC          | 19             |
            | BR01-522X      | Vaccination Status           | NULL                   | 20             |

    @Edit @HappyPath
    Scenario Outline: User attempts to edit lab translations for <entity_type> - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        And I click the "Edit" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I type "<systemCodeDescription>" into the autocomplete field and select the result
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"

        Examples:
            | Jira Issue Key | entity_type             | systemCodeDescription | entity_type_id |
            | BR01-123X      | Hospital Consultant     | HIMA                  | 7              |
            | BR01-123X      | Laboratory              | TO                    | 8              |
            | BR01-123X      | Requesting Organisation | GA                    | 6              |

    @Edit @HappyPath
    Scenario: User attempts to edit lab translations for GP - Autofill
        And I select "zTest" from the "filterBy" dropdown
        And I click the "GP" button
        And I click the "Add" button
        When I fill in the form fields as follows
            | Field              | Value    |
            | limsLaboratoryCode | <RANDOM> |
        And I type "VO" into the autocomplete field and select the result
        And I select "VON BERGEN FP CLINIC, VON BERGEN FP CLINIC" from the "gp" dropdown
        Then I click the "Save" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "5"


    @Delete
    Scenario Outline: User attempts to delete lab translations for <entity_type>
        And I select "zTest" from the "filterBy" dropdown
        And I click the "<entity_type>" button
        Then I click the "Delete [link]" button
        And I click the "Delete [button]" button
        And the records shown should reflect the "ods.cfg_lab_translation" table with "logical_delete_flag" of "0" and "lab_id" of "808" and "entity_type_id" of "<entity_type_id>"


        Examples:
            | Jira Issue Key | entity_type                  | entity_type_id |
            | BR01-522X      | Antimicrobial                | 1              |
            | BR01-522X      | Bacteraemia Source           | 2              |
            | BR01-522X      | Ethnicity Type               | 3              |
            | BR01-522X      | Feature                      | 4              |
            | BR01-522X      | Medical Specialty            | 9              |
            | BR01-522X      | Molecular Type               | 10             |
            | BR01-522X      | Organism                     | 11             |
            | BR01-522X      | Other Type                   | 12             |
            | BR01-522X      | Phage Type                   | 13             |
            | BR01-522X      | Requesting Organisation Type | 14             |
            | BR01-522X      | Sensitivity Result           | 15             |
            | BR01-522X      | Sero Type                    | 16             |
            | BR01-522X      | Specimen Type                | 17             |
            | BR01-522X      | Test Method                  | 18             |
            | BR01-522X      | Toxin                        | 19             |
            | BR01-522X      | Vaccination Status           | 20             |


