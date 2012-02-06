require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Description do
  before(:each) do
    @collection = Atrium::Collection.new
    @collection.save
    #@exhibit = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>1)
    #@exhibit.save
    @showcase = Atrium::Showcase.new(:showcases_id=>@collection.id, :showcases_type=>@collection.class.name)
    @showcase.save
    @description = Atrium::Description.new(:atrium_showcase_id=>@showcase.id)
    @description.save!
  end

  after(:each) do
    begin
      @description.delete
      @showcase.delete
      @collection.delete
    rescue
    end
  end

  describe "#descriptions" do
    it "should throw exception if try to create without showcase id" do
      threw_exception = false
      begin
        description=Atrium::Description.new
        description.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "should be able to delete an existing description" do
      Atrium::Description.destroy(@description.id)
    end
  end

  describe "#summary" do
    it "should be able to create summary" do
      pending
    end
    it "should be able to retrieve summary" do
      pending
    end
  end

  describe "#essay" do
    it "should be able to create essay" do
      pending
    end
    it "should be able to retrieve essay" do
      pending
    end
  end


end
