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
    it "should return the exhibit title" do
      @exhibit.update_attributes({:title=>"My title"})
      @exhibit.title.should == "My title"
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
    it "should return array of browse sets used in browsing" do
      @exhibit.showcases.create({:label=>"My Browse Set",:set_number=>1})
      @exhibit.showcases.create({:label=>"",:set_number=>2})
      (@exhibit.showcases.collect {|x| x.label}).should == ["My Browse Set",""]
    end

    it "should return browse sets sorted by set number" do
      @exhibit.showcases.create({:label=>"My Browse Set",:set_number=>2})
      @exhibit.showcases.create({:label=>"",:set_number=>1})
      (@exhibit.showcases.collect {|x| x.label}).should == ["","My Browse Set"]
    end
  end

  
end
