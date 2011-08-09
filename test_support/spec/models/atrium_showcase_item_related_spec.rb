require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase::Item::Related do
  before(:each) do
    @showcase = Atrium::Showcase.new
    @showcase.save
    @item = Atrium::Showcase::Item::Related.new({:atrium_showcase_id=>@showcase.id})
    @item.save
  end

  after(:each) do
    @item.delete
    @showcase.delete
  end

  describe "#type" do
    it "should return type Atrium::Showcase::Item::Related" do
      @item.type.should == "Atrium::Showcase::Item::Related"
    end
  end
end
