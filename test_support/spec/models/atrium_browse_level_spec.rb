require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowseLevel do
  before(:each) do
    @collection = Atrium::Collection.new
    @collection.save
    @exhibit = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>1)
    @exhibit.save
    @browse_level = Atrium::BrowseLevel.new(:atrium_exhibit_id=>@exhibit.id,:level_number=>1)
    @browse_level.save
  end

  after(:each) do
  end

  describe "#exhibit" do
    describe "#exhibit" do
      it "should return correct browse set" do
        @browse_level.exhibit.should == @exhibit
      end

      it "should throw an exception if exhibit not set" do
        @fail_browse_level = Atrium::BrowseLevel.new({:level_number=>1,:solr_facet_name=>"my_facet"})
        threw_exception = false
        begin
          @fail_browse_level.save!
        rescue
          threw_exception = true
        end
        threw_exception.should == true
      end
    end
  end

  describe "#level_number" do
    it "level number cannot be nil" do
      @fail_browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet"})
      threw_exception = false
      begin
        @fail_browse_level.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should return correct level number if set" do
      @browse_level.level_number = 1
    end
  end

  describe "#solr_filter_query" do
    it "should return nil if not set" do
      @browse_level.filter_query_params.nil?.should == true
    end

    it "should return correct value if set" do
      @browse_level.filter_query_params = "id:testing"
      @browse_level.filter_query_params.should == "id:testing"
    end
  end

  describe "#solr_facet_name" do
    it "solr facet name cannot be nil" do
       @fail_browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:level_number=>2})
      threw_exception = false
      begin
        @fail_browse_level.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "should return correct value if set" do
      @browse_level.solr_facet_name = "my_facet"
      @browse_level.solr_facet_name.should == "my_facet"
    end
  end

  describe "#label" do
    it "should return nil if not set" do
      @browse_level.label.nil?.should == true
    end

    it "should return correct value if set" do
      @browse_level.label = "my label"
      @browse_level.label.should == "my label"
    end
  end
end
