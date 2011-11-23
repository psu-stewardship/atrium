require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Collection do
  before(:each) do
    @collection = Atrium::Collection.new
    @collection.save
  end

  after(:each) do
    @collection.delete
  end

  describe "#title" do
    it "should return the collection title" do
      @collection.update_attributes({:title=>"My title"})
      @collection.title.should == "My title"
    end
  end

  describe "search_facets" do
    it "should return array of facets used in searching" do
      @collection.search_facets.create({:name=>"my_facet_2"})
      @collection.search_facets.create({:name=>"my_facet_4"})
      (@collection.search_facets.collect {|x| x.name}).should == ["my_facet_2","my_facet_4"]
    end
  end

  describe "exhibits" do
    it "should return array of browse sets used in browsing" do
      @collection.exhibits.create({:label=>"My Browse Set",:set_number=>1})
      @collection.exhibits.create({:label=>"",:set_number=>2})
      (@collection.exhibits.collect {|x| x.label}).should == ["My Browse Set",""]
    end

    it "should return browse sets sorted by set number" do
      @collection.exhibits.create({:label=>"My Browse Set",:set_number=>2})
      @collection.exhibits.create({:label=>"",:set_number=>1})
      (@collection.exhibits.collect {|x| x.label}).should == ["","My Browse Set"]
    end
  end

  
end
