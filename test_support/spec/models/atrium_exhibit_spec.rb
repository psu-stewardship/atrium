require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require "active_fedora"
#require "nokogiri"

describe Atrium::Exhibit do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
  end

  describe "#title" do
     it "should return empty string if no exhibit title defined" do
      @exhibit.title.should == ""
    end

    it "should return the exhibit title from descMetadata datastream if exhibit_title defined" do
      @exhibit.update_attributes({:title=>"My title"})
      @exhibit.title.should == "My title"
    end
  end

  describe "#build_members_query" do
    it "should return empty string if no members defined" do
      @exhibit.build_members_query.should == ""
    end

    it "should return a query string with delimiter AND and prefix _query_:" do
      @exhibit.queries.create({:value=>"id_t:RBSC-CURRENCY"})
      @exhibit.build_members_query.should == "_query_:\"id_t:RBSC-CURRENCY\""
      @exhibit.queries.create({:value=>"myfield:value"})
      @exhibit.build_members_query.should == "_query_:\"id_t:RBSC-CURRENCY\" AND _query_:\"myfield:value\""
    end
  end

  describe "#queries" do
    it "should return an array of solr query queries that will be used for filter queries" do
      @exhibit.queries.create({:value=>"id_t:RBSC-CURRENCY"})
      (@exhibit.queries.collect {|x| x.value }).should == ["id_t:RBSC-CURRENCY"]
      @exhibit.queries.create({:value=>"dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_t:Connecticut"})
      (@exhibit.queries.collect {|x| x.value }).should == ["id_t:RBSC-CURRENCY","dsc_0_collection_0_did_0_unittitle_0_imprint_0_publisher_t:Connecticut"]
    end
  end

  describe "browse_facets" do
    it "should return array of facets used in browsing" do
      @exhibit.browse_facets.create({:name=>"my_facet_1"})
      @exhibit.browse_facets.create({:name=>"my_facet_2"})
      (@exhibit.browse_facets.collect {|x| x.name}).should == ["my_facet_1","my_facet_2"]
    end
  end

  describe "browse_facet_names" do
    it "should return an array of browse facet names" do
      @exhibit.browse_facets.create({:name=>"my_facet_1"})
      @exhibit.browse_facets.create({:name=>"my_facet_2"})
      @exhibit.browse_facet_names.size.should == 2
      @exhibit.browse_facet_names.include?("my_facet_1").should == true
      @exhibit.browse_facet_names.include?("my_facet_2").should == true
    end

    it "if no browse facets defined it should return an empty array" do 
    end
  end

  describe "search_facets" do
    it "should return array of facets used in searching" do
      @exhibit.search_facets.create({:name=>"my_facet_2"})
      @exhibit.search_facets.create({:name=>"my_facet_4"})
      (@exhibit.search_facets.collect {|x| x.name}).should == ["my_facet_2","my_facet_4"]
    end
  end

  describe "showcases" do
    it "should return array of showcases defined" do
      pending "Need to define a test for checking showcases..."
    end
  end
end
