@atrium_collections

Feature: Collections
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an collection

  Scenario: Listing collections in home page
    Given User exists with a login of "test"
    Given I am on the home page
    #TODO how to handle if we have seeded collection
    Then I should see "Unnamed Collection"

  Scenario: Editor views the search results page and sees the add collection button
    Given User exists with a login of "test"
    Given I am on the home page
    Then I should see a "Create New Collection" button

  Scenario: Adding an Collection
    Given User exists with a login of "test"
    Given I am on the home page
    When I press "Create New Collection"
    Then I should be on the edit collection page for id 3
    And I should see a "h1" element containing "Editing Collection"

  Scenario: Configure a Collection
    Given User exists with a login of "test"
    Given "collection" exists with id 2
    And I am on the edit collection page for id 2
    And I fill in "atrium_collection_title" with "My Test Title"
    And I select "language_facet" from "atrium_collection_search_facet_names"
    And I press "Update Collection Configuration"
    Then I should see "My Test Title"
    And I should see select list "select#atrium_collection_search_facet_names" with "Language" selected
    When I am on the collection search page for id 2
    Then I should see a "h3" element containing "Language"
    And I should have "div.facet_limit" containing only 1 "h3"

    
  Scenario: Visiting collection scope page
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the edit collection page for id 1
    And I follow "Set Collection Scope"
    Then I should be on the catalog page
    And I should see a "div" tag with a "class" attribute of "ui-state-highlight"
    And I should see a "Set Collection Scope to Here" button

   Scenario: Adding a Scope to an collection
    Given User exists with a login of "test"
    Given "collection" exists with id 2
    And I am on the edit collection page for id 2
    And I follow "Set Collection Scope"
    And I should see a "Set Collection Scope to Here" button
    And I follow "Book"
    And I press "Set Collection Scope to Here"
    Then I should be on the edit collection page for id 2
    And I should see a "li" element containing "formatBook"

  Scenario: Adding Exhibit to Collection
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the edit collection page for id 1
    And I press "Add a Exhibit to this Collection"
    #TODO id will be different if we have seed data
    Then I should see "Exhibit 2"
    And I should see "Configure" link

  Scenario: Deleting Scope From collection
    Pending

  Scenario: Remove a Search Facet from existing collection
    pending

  Scenario: Follow Show collection Link from Configure collection Page
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the edit collection page for id 1
    And I follow "View Collection"
    Then I am on the collection home page for id 1

  Scenario: Validate Collection home page
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the collection home page for id 1
    Then I should see "Customize this page" link
    And I should see "Configure Collection" link
    And  I should see a search field
    And I should see a "Search" button

  Scenario: Adding Showcase to Collection
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the collection home page for id 1
    And I follow "Customize this page"
    Then I should have showcase for collection with id 1
    And I should see "View this page" link
    And I should see "Select Featured Items" link
    And I should see "Add New Description" link
    And I should see "Stop Editing" link

   Scenario: Adding new description
    Given User exists with a login of "test"
    And I am on the collection home page for id 1
    And I follow "Customize this page"
    And I follow "Add New Description"
    Then I should have "essay" field
    And I should have "summary" field
    When I add "essay" with content "this is new description" to the collection with id "1"
    And "showcase" exists with id 1
    Then I am on the collection page with id 1 having showcase with id 1
    And I should see "Edit Description" link
    And I should see "Delete this description" link
    When I follow "Stop Editing"
    And I should see "this is new description"

  Scenario: Delete description
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the collection home page for id 1
    And I follow "Customize this page"
    And I follow "Add New Description"
    When I add "essay" with content "this is new description" to the collection with id "1"
    And I follow "Delete this description"
    When I follow "Stop Editing"
    And I should not see "essay"

  Scenario: Adding featured items to Collection
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the collection home page for id 1
    And I follow "Customize this page"
    And I follow "Select Featured Items"
    Then I should see "You can use either use search form or facet to search for items to be added featured source. Please use selected checkbox to select item"
    When I add record "2009373513" to featured to the "collection" with id "1" and facet ""
    Then I am on the collection page with id 1 having showcase with id 1
    And I should have link to "ci-an-zhou-bian" in featured list

  Scenario: Modifying featured items from Collection
    Pending

  Scenario: Delete Collection
    Given User exists with a login of "test"
    Given "collection" exists with id 1
    And I am on the edit collection page for id 1
    And I should see "Delete this Collection" link