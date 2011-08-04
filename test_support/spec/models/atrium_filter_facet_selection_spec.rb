require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Filter::FacetSelection do
  before(:each) do
    @facet = Atrium::Filter::Facet.new
    @facet.save
    @showcase = Atrium::Showcase.new
    @showcase.save
    @facet_selection = Atrium::Filter::FacetSelection.new({:atrium_showcase_id=>@showcase.id, :atrium_filter_facet_id=>@facet.id})
  end

  after(:each) do
    @facet_selection.delete
    @facet.delete
    @showcase.delete
    begin
      @fail_facet_selection.delete
    rescue
    end
  end

  describe "#value" do
    it "should return an empty string if no value set" do
      @facet_selection.value.should == ""
    end

    it "should return the correct value if set" do
      @facet_selection.value = "connecticut"
      @facet_selection.value.should == "connecticut"
    end
  end

  describe "#facet" do
    it "facet cannot be null" do
      @fail_facet_selection = Atrium::Filter::FacetSelection.new({:atrium_showcase_id=>@showcase.id})
      threw_exception = false
      begin
        @fail_facet_selection.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
  end

  describe "#showcase" do
    it "showcase cannot be null" do
      @fail_facet_selection = Atrium::Filter::FacetSelection.new({:atrium_filter_facet_id=>@facet.id})
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
