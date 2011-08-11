Then /^I should not see select list "([^\"]*)" with field labels "([^\"]*)"$/ do |list_css, names|
  response.should have_tag(list_css) do
    labels = names.split(", ")
    labels.each do |label|
      without_tag('option', label)
    end
  end
end
