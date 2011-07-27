# This is borrowed from blacklight's record_view_steps.rb
Then /^I (should|should not) see an? "([^\"]*)" element containing "([^\"]*)"$/ do |bool,elem,content|
  if bool == "should"
    response.should have_selector("#{elem}",:content => content)
  else
    response.should_not have_selector("#{elem}",:content => content)
  end
end