require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase::FacetSelection do
  before(:each) do
    @showcase = Atrium::Showcase.new
    @showcase.save
    @facet_selection = Atrium::Showcase::FacetSelection.new({:atrium_showcase_id=>@showcase.id, :value=>"connecticut", :solr_facet_name=>"publisher_facet"})
  end

  after(:each) do
    @facet_selection.delete
    @showcase.delete
    begin
      @fail_facet_selection.delete
    rescue
    end
  end

  describe "#value" do
    it "value cannot be nil" do
      @fail_facet_selection = Atrium::Showcase::FacetSelection.new({:atrium_showcase_id=>@showcase.id,:solr_facet_name=>"my_facet"})
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
      @fail_facet_selection = Atrium::Showcase::FacetSelection.new({:atrium_showcase_id=>@showcase.id})
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

  describe "#showcase" do
    it "showcase cannot be null" do
      @fail_facet_selection = Atrium::Showcase::FacetSelection.new({:solr_facet_name=>"my_facet"})
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
