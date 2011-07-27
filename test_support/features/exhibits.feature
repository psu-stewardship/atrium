=begin
@atrium_exhibits

Feature: Exhibits
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an exhibit

  Scenario: Editor views the search results page and sees the add exhibit button
    Given I am logged in as "archivist1"
    Given I am on the base search page
    Then I should see "Add an Exhibit" within "div#create-asset-box"
     
  Scenario: Adding an exhibit
    Given I am logged in as "archivist1"
    And I am on the new exhibit page
    Then I should see a "dt" element containing "Title:"
    And I should see a "dd" element containing ""
    And I should see a "dt" element containing "Query Value:"
    And I should see a "dd" element containing ""
    And I should see a "Save" button
    Then I should see select list "select#atrium_exhibit_browse_facets_attributes_0_name" with field labels "Publisher, Print Date, Printing Location, Printer, Engraver, Signers, Print Year"
    And I should see a "Add Browse Facet" button 
    And I press "Save"
    Then I should see "Exhibit was successfully created."

  Scenario: Editing an exhibit and apply query filter
    Given I am logged in as "archivist1"
    And I am on the edit exhibit page for id 1
    And I fill in "title" with "My Exhibit"
    And I fill in "atrium_exhibit_queries_attributes_0_value" with "date_s:1775"
    And I press "Save"
    Then I should see "Exhibit was successfully updated."
    And I should see "View" within "a.browse" 
    Then I follow "View"
    And I should see "3 documents found"
    Then I follow "Edit"
    And I fill in "atrium_exhibit_queries_attributes_0_value" with "id:ead*"
    And I press "Save"
    Then I should see "Exhibit was successfully updated."
    Then I follow "View"
    And I should see "8 documents found"
    

  Scenario: Adding and deleting browse facet from exhibit
    Given I am logged in as "archivist1"
    And I am on the edit exhibit page for id 1
    When I select "Print Date" from "atrium_exhibit_browse_facets_attributes_0_name"
    And I press "Add Browse Facet"
    Then I should see "Exhibit was successfully updated."
    And I should see a "td" element containing "Print Date"
    And I should not see select list "select#atrium_exhibit_browse_facets_attributes_0_name" with field labels "Print Date"
    When I check "atrium_exhibit_browse_facets_attributes_0__destroy"
    And I press "Save"
    Then I should see "Exhibit was successfully updated."
    Then I should not see a "td" element containing "Print Date"
    And I should see select list "select#atrium_exhibit_browse_facets_attributes_0_name" with field labels "Print Date"

  Scenario: Adding and deleting search facet from exhibit
    Given I am logged in as "archivist1"
    And I am on the edit exhibit page for id 1
    When I select "Print Date" from "atrium_exhibit_search_facets_attributes_0_name"
    And I press "Add Search Facet"
    Then I should see "Exhibit was successfully updated."
    And I should see a "td" element containing "Print Date"
    And I should not see select list "select#atrium_exhibit_search_facets_attributes_0_name" with field labels "Print Date"
    When I check "atrium_exhibit_search_facets_attributes_0__destroy"
    And I press "Save"
    Then I should see "Exhibit was successfully updated."
    Then I should not see a "td" element containing "Print Date"
    And I should see select list "select#atrium_exhibit_search_facets_attributes_0_name" with field labels "Print Date"
=end
  