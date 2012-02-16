
Then /^"([^"]*)" should( not)? be an option for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, negate, field, selector|
  with_scope(selector) do
    expectation = negate ? :should_not : :should
    field_labeled(field).first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
  end
end

Given /^I follow the "([^"]*)" link for exhibit with id (\d+)$/ do |link, id|
  page.find(:xpath, ".//li[@data-id = #{id}]/span[@class='controls']/a[text()='#{link}']").click
end



Then /^I should have "([^"]*)" containing only (\d+) "([^"]*)"$/ do |selector, count, element |
  page.should have_css("#{selector} #{element}", :count => count.to_i)
end

Then /^I should have the applied solr facet "([^\"]*)" with the value "([^\"]*)"$/ do |filter, text|
  page.should have_selector("div.facet-list") do |node|
    node.should have_selector("h3", :content => filter)
    node.should have_selector("span.selected", :content => text)
  end
end

Then /^I should have "([^\"]*)" facet inside "([^\"]*)" facet$/ do |string, filter|
  Then %Q{I should see "#{string}" within "li##{filter} h3.facet-heading"}
end

Then /^I should have showcase for exhibit with id "([^"]*)" and facet "([^"]*)"$/ do |exhibit_id, facet|
  exhibit= Atrium::Exhibit.find(exhibit_id)
  showcase= Atrium::Showcase.with_selected_facets(exhibit_id,exhibit.class.name, {"pub_date"=>["#{facet}"]}).first
  #puts "Showcase: #{showcase.inspect}"
  showcase.should_not be nil
end


When /^I add "([^"]*)" with content "([^"]*)" to the exhibit with id "([^"]*)" and facet "([^"]*)"$/ do |field, content, id, facet|
  exhibit= Atrium::Exhibit.find(id)
  showcase= Atrium::Showcase.with_selected_facets(id,exhibit.class.name, {"pub_date"=>["#{facet}"]}).first
  fill_in "atrium_description_#{field}_attributes_content", :with => content
  click_button "Update"
  page.should have_content(content)
  visit atrium_exhibit_path(exhibit.id, :f=>{"pub_date"=>["#{facet}"]})
end



