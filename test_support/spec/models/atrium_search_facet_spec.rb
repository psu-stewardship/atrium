require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Search::Facet do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @filter_facet = Atrium::Search::Facet.new({:atrium_exhibit_id=>@exhibit.id,:name=>"my_facet"})
    @filter_facet.save
  end

  after(:each) do
    @filter_facet.delete
    @exhibit.delete
    begin
    @fail_facet.delete
    rescue
    end
  end

  describe "#name" do
    it "should return correct name if set" do
      @filter_facet.name = "my_facet"
      @filter_facet.name.should == "my_facet"
    end

    it "name must be defined" do
      @fail_facet = Atrium::Search::Facet.new({:atrium_exhibit_id=>@exhibit.id})
      threw_exception = false
      begin
        @fail_facet.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
  end

  describe "#atrium_exhibit" do
    it "atrium exhibit cannot be null" do
        @fail_facet = Atrium::Search::Facet.new({:name=>"my_facet"})
      threw_exception = false
      begin
        @fail_facet.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "atrium exhibit should be correct" do
      @filter_facet.exhibit.should == @exhibit
    end
  end
end
