require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Filter::Facet::SearchFacet do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @filter_facet = Atrium::Filter::Facet::SearchFacet.new({:atrium_exhibit_id=>@exhibit.id})
    @filter_facet.save
  end

  after(:each) do
    @filter_facet.delete
    @exhibit.delete
  end

  describe "#type" do
    it "should return type SearchFacet" do
      @filter_facet.type.should == "Atrium::Filter::Facet::SearchFacet"
    end
  end
end
