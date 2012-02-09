
Then /^"([^"]*)" should( not)? be an option for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, negate, field, selector|
  with_scope(selector) do
    expectation = negate ? :should_not : :should
    field_labeled(field).first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
  end
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
