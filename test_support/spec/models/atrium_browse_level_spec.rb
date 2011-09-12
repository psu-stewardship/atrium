require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowseLevel do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @browse_set = Atrium::BrowseSet.new(:atrium_exhibit_id=>@exhibit.id,:set_number=>1)
    @browse_set.save
    @browse_level = Atrium::BrowseLevel.new(:atrium_browse_set_id=>@browse_set.id,:level_number=>1)
    @browse_level.save
  end

  after(:each) do
  end

  describe "#browse_set" do
    describe "#browse_set" do
      it "should return correct browse set" do
        @browse_level.browse_set.should == @browse_set
      end

      it "should throw an exception if browse_set not set" do
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
      @fail_browse_level = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet"})
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
      @browse_level.solr_filter_query.nil?.should == true
    end

    it "should return correct value if set" do
      @browse_level.solr_filter_query = "id:testing"
      @browse_level.solr_filter_query.should == "id:testing"
    end
  end

  describe "#solr_facet_name" do
    it "solr facet name cannot be nil" do
       @fail_browse_level = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:level_number=>2})
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
