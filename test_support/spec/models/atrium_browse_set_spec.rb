require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowseSet do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @browse_set = Atrium::BrowseSet.new(:atrium_exhibit_id=>@exhibit.id,:set_number=>1)
    @browse_set.save
  end

  after(:each) do
    @browse_set.delete
    @exhibit.delete
  end

  describe "#label" do
    it "should return empty string if no browse set label defined" do
      @browse_set.label.should == ""
    end

    it "should return the browse set label" do
      @browse_set.update_attributes({:label=>"My label"})
      @browse_set.label.should == "My label"
    end
  end

  describe "browse_facet_names" do
    it "should return an array of browse facet names" do
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>1})
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>2})
      @browse_set.browse_facet_names.size.should == 2
      @browse_set.browse_facet_names.include?("my_facet_1").should == true
      @browse_set.browse_facet_names.include?("my_facet_2").should == true
    end

    it "should remove associated showcases if a browse facet removed" do
      #pending "need to test that associated showcases are removed if a browse facet is removed..."
      val = true
      val.should == ""
    end

    it "if no browse facets defined it should return an empty array" do 
      @browse_set.browse_facet_names.should == []
    end
  end

  describe "browse_levels" do
    it "should return array of levels used in browsing" do
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>1})
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>2})
      (@browse_set.browse_levels.collect {|x| x.solr_facet_name}).should == ["my_facet_1","my_facet_2"]
    end

    it "should return browse levels sorted by level number" do
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_1",:label=>"My Category",:level_number=>2})
      @browse_set.browse_levels.create({:solr_facet_name=>"my_facet_2",:label=>"",:level_number=>1})
      (@browse_set.browse_levels.collect {|x| x.solr_facet_name}).should == ["my_facet_2","my_facet_1"]
    end
  end
  
  describe "#solr_filter_query" do
    it "should return the solr filter query if any for the top of this browse set" do
      @exhibit.solr_filter_query = "id_t:RBSC-CURRENCY"
      @exhibit.solr_filter_query.should == "id_t:RBSC-CURRENCY"
    end
  end

  describe "showcases" do
    it "should return array of showcases defined" do
      @showcase = @browse_set.showcases.create
      @showcase2 = @browse_set.showcases.create
      @browse_set.showcases.size.should == 2
      @browse_set.showcases.include?(@showcase).should == true
      @browse_set.showcases.include?(@showcase2).should == true
    end
  end
end
