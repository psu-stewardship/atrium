@atrium_exhibits

Feature: Exhibits
  In order to create a custom browse exhibit
  As as user
  I want to create and configure an Exhibit within collection

  Scenario: Editing a title in a exhibit
    Given User exists with a login of "test"
    Given "collection" exists with id 2
    Given "exhibit" exists with id 2
    And I am on the edit collection page for id 2
    And I follow the "Configure" link for exhibit with id 2
    Then I am on the exhibit edit page for id 2
    When I fill in "atrium_exhibit_label" with "My Test Exhibit"
    And I press "Update Exhibit and Facets"
    Then I should see "My Test Exhibit"

  Scenario: Visiting exhibit scope page
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I follow "Set Exhibit Scope"
    Then I should be on the catalog page
    And I should see a "div" tag with a "class" attribute of "ui-state-highlight"
    And I should see a "Set Exhibit Scope to Here" button

  ## this scenario requires Format facet to be set as Collection Search Facet
   Scenario: Adding a Scope to an Exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    And I should see a "Set Exhibit Scope to Here" button
    And I follow "Book"
    And I press "Set Exhibit Scope to Here"
    Then I am on the exhibit edit page for id 1
    And I should see a "li" element containing "formatBook"

  Scenario: Add and Remove a Scope from exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    And I should see a "Set Exhibit Scope to Here" button
    And I follow "Book"
    And I press "Set Exhibit Scope to Here"
    Then I should see a "li" element containing "formatBook"
    And I follow "Remove Exhibit Scope"
    Then I should not see a "li" element containing "formatBook"

  Scenario: Adding a solr facet to exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And "Format" should be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"

  Scenario: Adding more than one solr facet to exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I select "Format" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    And "Format" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"

    # Need pre-defined exhibits with publication year facet selected, Right now it is part of the scenario
  Scenario: View exhibit in collection home page
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I select "Publication Year" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    When I am on the collection home page for id 2
    Then I should see a "div" tag with a "class" attribute of "facet-list"
    And I should see a "h3" element containing "Publication Year"
    And I should have "div.facet-list" containing only 2 "h3"
    When I follow "2008"
    Then I should have the applied solr facet "Publication Year" with the value "2008"

  Scenario: Browsing Nested Solr Facets on Exhibit from collection home page
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I select "Publication Year" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Publication Year" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    And "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I am on the collection home page for id 2
    Then I should see a "div" tag with a "class" attribute of "facet-list"
    And I should see a "h3" element containing "Publication Year"
    When I follow "2008"
    Then I should have the applied solr facet "Publication Year" with the value "2008"
    And I should have "Language" facet inside "2008" facet
    When I follow "Tibetan"
    Then I should have the applied solr facet "Language" with the value "Tibetan"

 Scenario: Adding Showcase to selected facet
   Given User exists with a login of "test"
   When I am on the collection home page for id 1
   And I follow "2008"
   Then I should have the applied solr facet "Publication Year" with the value "2008"
   When I follow "Customize this page"
   Then I should have showcase for exhibit with id "1" and facet "2008"
   And I should see "View this page" link
   And I should see "Select Featured Items" link
   And I should see "Add New Description" link
   And I should see "Stop Editing" link

 Scenario: Adding description to Showcase of the selected facet
   Given User exists with a login of "test"
   When I am on the collection home page for id 1
   And I follow "2008"
   Then I should have the applied solr facet "Publication Year" with the value "2008"
   When I follow "Customize this page"
   Then I should have showcase for exhibit with id "1" and facet "2008"
   And I follow "Add New Description"
   Then I should have "essay" field
   And I should have "summary" field
   When I add "essay" with content "this is exhibit description for facet 2008" to the exhibit with id "2" and facet "2008"
   Then I am on the exhibit home page for id 1 with facet "2008"
   And I should see "Edit Description" link
   And I should see "Delete this description" link
   When I follow "Stop Editing"
   And I should see "this is exhibit description for facet 2008" within "ul.description"

 Scenario: Adding featured to Showcase of the selected facet
   Given User exists with a login of "test"
   When I am on the collection home page for id 1
   And I follow "2008"
   Then I should have the applied solr facet "Publication Year" with the value "2008"
   When I follow "Customize this page"
   And I follow "Select Featured Items"
   Then I should see "You can use either use search form or facet to search for items to be added featured source. Please use selected checkbox to select item"
   When I add record "2007020969" to featured to the "Exhibit" with id "1" and facet "2008"
   Then I am on the exhibit home page for id 1 with facet "2008"
   And I should have link to "Strong Medicine speaks" in featured list

#TODO this scenario is not clear to me
  Scenario: Add group by filter to facet in exhibit
    Pending
    #Given User exists with a login of "test"
    #And I am on the exhibit edit page for id 1
    #And I follow "Set Exhibit Scope"
    #And I should see a "Set Browse Level Scope to Here" button
    #And I follow "Book"
    #And I press "Set Browse Level Scope to Here"

  Scenario: Remove a exhibit
    pending

  Scenario: Add another exhibit
    pending

  Scenario: Toggle between view on one exhibit and another exhibit
    pending



 Scenario: View Exhibit with facet selected and showcase defined




