require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should see "([^"]*)" link(?: within "([^"]*)")?$/ do |link_locator, scope_selector|
  with_scope(scope_selector) do
    begin
      find_link(link_locator)
    rescue
      raise "no link with value or id or text '#{link_locator}' found"
    end
  end
end

Then /^I (should not|should) see an? "([^\"]*)" tag with an? "([^\"]*)" attribute of "([^\"]*)"$/ do |bool,tag,attribute,value|
  if bool == "should not"
    page.should_not have_xpath("//#{tag}[contains(@#{attribute}, #{value})]")
  else
    page.should have_xpath("//#{tag}[contains(@#{attribute}, #{value})]")
  end
end

Given /^User exists with a login of "([^\"]*)"$/ do |login|
  email = "#{login}@#{login}.com"
  User.find_by_email(email).should_not be_nil
  visit destroy_user_session_path
  visit new_user_session_path
  fill_in "Email", :with => email
  fill_in "Password", :with => "test123"
  click_button "Sign in"
  Then 'I should see "Log Out"'
end

Then /^I should have showcase for collection with id (\d+)$/ do |collection_id|
  collection= Atrium::Collection.find(collection_id)
  showcase= Atrium::Showcase.with_selected_facets(collection_id,collection.class.name, nil).first
  showcase.should_not be nil
end

Then /^I should have "([^\"]*)" field$/ do  |field_name|
  page.should have_selector("textarea#atrium_description_#{field_name}_attributes_content")
end

When /^I add "([^"]*)" with content "([^"]*)" to the collection with id "([^"]*)"$/ do |field, content, collection_id|
  collection= Atrium::Collection.find(collection_id)
  showcase= Atrium::Showcase.with_selected_facets(collection_id,collection.class.name, nil).first
  fill_in "atrium_description_#{field}_attributes_content", :with => content
  click_button "Update"
  page.should have_content(content)
  visit atrium_collection_showcase_path(collection.id, showcase.id, nil)
end

When /^I (add|remove) record (.+) (to|from) featured for showcase with id (.+)$/ do |add_or_remove, id, wording,showcase_id|
  click_button("folder_submit_#{id}")
  showcase= Atrium::Showcase.find(showcase_id)
  collection= Atrium::Collection.find(showcase.showcases_id)
  visit atrium_collection_atrium_showcases_path(collection, :showcase_id => showcase.id)
end

Then /^I should have link to "([^"]*)" in featured list$/ do |name|
  save_and_open_page
  puts "#{page.find("span#show_selected div#documents div.document h3.index_title a")['href'].inspect}"
  #page.should have_xpath("span#show_selected a[@href ='#{catalog_path(id)}']")
  page.should have_selector("span#show_selected div#documents div.document h3.index_title", :content => name)
end

#Then /^I should have summary field$/ do
#  page.should have_selector("textarea#atrium_description_summary_attributes_content")
#end


