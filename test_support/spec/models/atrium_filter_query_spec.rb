require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Filter::Query do

  before(:each) do
    @filter_query = Atrium::Filter::Query.new
    @filter_query.save
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
  end

  after(:each) do
    @filter_query.delete
    @exhibit.delete
  end

  describe "#value" do
    it "should return an empty string if no value set" do
      @filter_query.value.should == ""
    end

    it "should return the correct value string" do
      @filter_query.value = "test_value"
      @filter_query.value.should == "test_value"
    end
  end

  describe "#atrium_exhibit" do
    it "should return the exhibit this belongs to" do
      @exhibit.queries << @filter_query
      @filter_query.atrium_exhibit.should == @exhibit
    end

    it "should return nil if no exhibit defined" do
      @filter_query.atrium_exhibit.nil?.should == true
    end
  end
end
