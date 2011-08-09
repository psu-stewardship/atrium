require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase::Item::Featured do
  before(:each) do
    @showcase = Atrium::Showcase.new
    @showcase.save
    @item = Atrium::Showcase::Item::Featured.new({:atrium_showcase_id=>@showcase.id})
    @item.save
  end

  after(:each) do
    @item.delete
    @showcase.delete
  end

  describe "#type" do
    it "should return type Atrium::Showcase::Item::Featured" do
      @item.type.should == "Atrium::Showcase::Item::Featured"
    end
  end
end
