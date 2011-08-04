require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Item do
  before(:each) do
    @showcase = Atrium::Showcase.new
    @showcase.save
    @item = Atrium::Item.new({:atrium_showcase_id=>@showcase.id})
    @item.save
  end

  after(:each) do
    @showcase.delete
    @item.delete
    begin
    @fail_item.delete
    rescue
    end
  end

  describe "#type" do
    it "should return the type of this item" do
      @item.type = "Description"
      @item.type.should == "Description"
    end
    
    it "should return nil if type not set" do
      @item.type.nil?.should == true
    end
  end

  describe "#showcase" do
    it "showcase cannot be null" do
      @fail_item = Atrium::Item.new
      threw_exception = false
      begin
        @fail_item.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end

    it "showcase should be correct" do
      @item.showcase.should == @showcase
    end
  end
end
