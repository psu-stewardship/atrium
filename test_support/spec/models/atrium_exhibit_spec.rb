require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Exhibit do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
  end

  after(:each) do
    @exhibit.delete
  end

  describe "#title" do
    it "should return empty string if no exhibit title defined" do
      @exhibit.title.should == ""
    end

    it "should return the exhibit title" do
      @exhibit.update_attributes({:title=>"My title"})
      @exhibit.title.should == "My title"
    end
  end

  describe "#build_members_query" do
    it "should return empty string if no members defined" do
      @exhibit.build_members_query.should == ""
    end

    it "should return a query string with delimiter AND and prefix _query_:" do
      @exhibit.solr_filter_query = "id_t:RBSC-CURRENCY"
      @exhibit.solr_filter_query.should == "id_t:RBSC-CURRENCY"
      @exhibit.build_members_query.should == "_query_:\"id_t:RBSC-CURRENCY\""
    end
  end

  describe "#solr_filter_query" do
    it "should return an array of solr query queries that will be used for filter queries" do
      @exhibit.solr_filter_query = "id_t:RBSC-CURRENCY"
      @exhibit.solr_filter_query.should == "id_t:RBSC-CURRENCY"
    end
  end

  describe "search_facets" do
    it "should return array of facets used in searching" do
      @exhibit.search_facets.create({:name=>"my_facet_2"})
      @exhibit.search_facets.create({:name=>"my_facet_4"})
      (@exhibit.search_facets.collect {|x| x.name}).should == ["my_facet_2","my_facet_4"]
    end
  end

  describe "browse_sets" do
    it "should return array of browse sets used in browsing" do
      @exhibit.browse_sets.create({:label=>"My Browse Set",:set_number=>1})
      @exhibit.browse_sets.create({:label=>"",:set_number=>2})
      (@exhibit.browse_sets.collect {|x| x.label}).should == ["My Browse Set",""]
    end

    it "should return browse sets sorted by set number" do
      @exhibit.browse_sets.create({:label=>"My Browse Set",:set_number=>2})
      @exhibit.browse_sets.create({:label=>"",:set_number=>1})
      (@exhibit.browse_sets.collect {|x| x.label}).should == ["","My Browse Set"]
    end
  end

  
end
