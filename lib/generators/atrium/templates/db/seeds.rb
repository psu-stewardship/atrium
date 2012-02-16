# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

#############################################
# User Configuration
#############################################
email= "test@test.com"
if User.find_by_email(email).nil?
  user= User.create(:email => email, :password => "password", :password_confirmation => "password")
else
  user=  User.find_by_email(email)
end
puts "user created: #{user.inspect}"

#############################################
# Collection Configuration
#############################################

collection= Atrium::Collection.create
search_facet= Atrium::Search::Facet.create([{:name=> "format", :atrium_collection_id=> collection.id}])
puts "collection created: #{collection.inspect}, search_facet: #{search_facet.inspect}"
collection2=Atrium::Collection.create

#############################################
# Exhibit Configuration
#############################################
exhibit= Atrium::Exhibit.create([{:set_number=> 1, :atrium_collection_id=> collection.id, :label=> "Exhibit 1"}])
exhibit2= Atrium::Exhibit.create([{:set_number=> 1, :atrium_collection_id=> collection2.id, :label=> "Exhibit 1"}])
puts "exhibit created: #{exhibit.inspect}"
facet1=Atrium::BrowseLevel.create([{:atrium_exhibit_id=>1, :level_number=>1, :solr_facet_name=>'pub_date', :label=>'Publication Year'}])
facet2=Atrium::BrowseLevel.create([{:atrium_exhibit_id=>1, :level_number=>2, :solr_facet_name=>'language_facet', :label=>'Language'}])
