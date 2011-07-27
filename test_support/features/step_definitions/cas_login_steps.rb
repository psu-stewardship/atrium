require 'casclient/frameworks/rails/filter'

Given /^I am logged in with netid "([^\"]*)"$/ do |login|
  ::CASClient::Frameworks::Rails::Filter.fake(login)
  current_user=User.create_from_ldap(login)
  User.find(current_user.id).should_not be_nil
end
