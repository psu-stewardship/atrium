require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase do
  before(:each) do
    @showcase = Atrium::Showcase.new
    @showcase.save
  end

  after(:each) do
    @item.delete
    begin
    @fail_item.delete
    rescue
    end
  end

  describe "#featured_items" do
    it "should test featured items" do
      pending "featured item test...."
    end
  end

  describe "#related_items" do
    it "should test related items" do
      pending "related item test...."
    end
  end

  describe "#descriptions" do
    it "should test descriptions" do
      pending "description item test...."
    end
  end

  describe "#exhibit" do
    it "should return correct exhibit" do
      pending "exhibit test...."
    end

    it "should throw an exception if agent not set" do
    end
  end

  describe "#facet_selections" do
    it "should test facet selections" do
      pending "should test facet selections"
    end
  end

  describe "#facets" do
    it "should test facets" do
      pending "should test facets"
    end
  end
end
