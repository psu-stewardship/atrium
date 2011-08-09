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

  describe "browse_levels" do
    it "should return array of levels used in browsing" do
      @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>1})
      @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>2})
      (@exhibit.browse_levels.collect {|x| x.solr_facet_name}).should == ["my_facet_1","my_facet_2"]
    end

    it "should return browse levels sorted by level number" do
       @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>2})
      @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>1})
      (@exhibit.browse_levels.collect {|x| x.solr_facet_name}).should == ["my_facet_2","my_facet_1"]
    end
  end

  describe "browse_facet_names" do
    it "should return an array of browse facet names" do
      @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>1})
      @exhibit.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>2})
      @exhibit.browse_facet_names.size.should == 2
      @exhibit.browse_facet_names.include?("my_facet_1").should == true
      @exhibit.browse_facet_names.include?("my_facet_2").should == true
    end

    it "should remove associated showcases if a browse facet removed" do
      #pending "need to test that associated showcases are removed if a browse facet is removed..."
      val = true
      val.should == ""
    end

    it "if no browse facets defined it should return an empty array" do 
      @exhibit.browse_facet_names.should == []
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
      @showcase = @exhibit.showcases.create
      @showcase2 = @exhibit.showcases.create
      @exhibit.showcases.size.should == 2
      @exhibit.showcases.include?(@showcase).should == true
      @exhibit.showcases.include?(@showcase2).should == true
    end
  end
end
