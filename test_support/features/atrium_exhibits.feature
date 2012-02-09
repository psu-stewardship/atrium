@atrium_exhibits

Feature: Exhibits
  In order to create a custom browse exhibit
  As as user
  I want to create and configure an Exhibit within collection

  Scenario: Editing a title in a exhibit
    Given User exists with a login of "test"
    And I am on the edit collection page for id 1
    And I follow "Configure"
    Then I am on the exhibit edit page for id 1
    When I fill in "atrium_exhibit_label" with "My Test Exhibit"
    And I press "Update Exhibit and Facets"
    Then I should see "My Test Exhibit"

  Scenario: Visiting exhibit scope page
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    Then I should be on the catalog page
    And I should see a "div" tag with a "class" attribute of "ui-state-highlight"
    And I should see a "Set Exhibit Scope to Here" button

  ## this scemario need Format to be set as Collection Search Facet
   Scenario: Adding a Scope to an Exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    And I should see a "Set Exhibit Scope to Here" button
    And I follow "Book"
    And I press "Set Exhibit Scope to Here"
    #Then I am on the edit exhibit page for id 1
    Then I should see a "li" element containing "formatBook"

  Scenario: Add and Remove a Scope from exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    And I should see a "Set Exhibit Scope to Here" button
    And I follow "Book"
    And I press "Set Exhibit Scope to Here"
    #Then I am on the edit exhibit page for id 1
    Then I should see a "li" element containing "formatBook"
    And I follow "Remove Exhibit Scope"
    Then I should not see a "li" element containing "formatBook"

  Scenario: Adding a solr facet to exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And "Format" should be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"

  Scenario: Adding more than one solr facet to exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I select "Format" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    And "Format" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"

  #TODO this scenario is not clear to me
  Scenario: Add a Browse Level Scope from exhibit
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 1
    And I follow "Set Exhibit Scope"
    And I should see a "Set Browse Level Scope to Here" button
    And I follow "Book"
    And I press "Set Browse Level Scope to Here"

    # Need pre-defined exhibits with publication year facet selected
  Scenario: View exhibit in collection home page
    Given User exists with a login of "test"
    And I am on the collection home page for id 1
    Then I should see a "div" tag with a "class" attribute of "facet-list"
    And I should see a "h3" element containing "Publication Year"
    And I should have "div.facet-list" containing only 2 "h3"
    When I follow "2008"
    Then I should have the applied solr facet "Publication Year" with the value "2008"

  Scenario: Browsing Solr Facets on Exhibit from collection home page
    Given User exists with a login of "test"
    And I am on the exhibit edit page for id 2
    And I select "Language" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    Then "Language" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I select "Publication Year" from "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    And I press "Add A Facet"
    And "Publication Year" should not be an option for "atrium_exhibit_browse_levels_attributes_0_solr_facet_name"
    When I am on the collection home page for id 1
    Then I should see a "div" tag with a "class" attribute of "facet-list"
    And I should see a "h3" element containing "Language"
    When I follow "Tibetan"
    Then I should have the applied solr facet "Language" with the value "Tibetan"

  Scenario: Remove a exhibit
    pending

  Scenario: Add another exhibit
    pending

  Scenario: Toggle between view on one exhibit and another
    pending
