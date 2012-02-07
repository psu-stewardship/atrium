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