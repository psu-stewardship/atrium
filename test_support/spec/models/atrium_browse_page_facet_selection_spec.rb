require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowsePage::FacetSelection do
  before(:each) do
    @browse_page = Atrium::BrowsePage.new
    @browse_page.save
    @facet_selection = Atrium::BrowsePage::FacetSelection.new({:atrium_browse_page_id=>@browse_page.id, :value=>"connecticut", :solr_facet_name=>"publisher_facet"})
  end

  after(:each) do
    @facet_selection.delete
    @browse_page.delete
    begin
      @fail_facet_selection.delete
    rescue
    end
  end

  describe "#value" do
    it "value cannot be nil" do
      @fail_facet_selection = Atrium::BrowsePage::FacetSelection.new({:atrium_browse_page_id=>@browse_page.id,:solr_facet_name=>"my_facet"})
      threw_exception = false
      begin
        @fail_facet_selection.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "should return the correct value if set" do
      @facet_selection.value.should == "connecticut"
    end
  end

  describe "#solr_facet_name" do
    it "facet cannot be null" do
      @fail_facet_selection = Atrium::BrowsePage::FacetSelection.new({:atrium_browse_page_id=>@browse_page.id})
      threw_exception = false
      begin
        @fail_facet_selection.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "should return the correct value if set" do
      @facet_selection.solr_facet_name.should == "publisher_facet"
    end
  end

  describe "#browse_page" do
    it "browse_page cannot be null" do
      @fail_facet_selection = Atrium::BrowsePage::FacetSelection.new({:solr_facet_name=>"my_facet"})
      threw_exception = false
      begin
        @fail_facet_selection.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
  end
end
