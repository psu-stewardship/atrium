require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase::Item::Description do
  before(:each) do
    @browsepage = Atrium::Showcase.new
    @browsepage.save
    @item = Atrium::Showcase::Item::Description.new({:atrium_showcase_id=>@browsepage.id})
    @item.save
  end

  after(:each) do
    @item.delete
    @browsepage.delete
  end

  describe "#type" do
    it "should return type Atrium::Showcase::Item::Description" do
      @item.type.should == "Atrium::Showcase::Item::Description"
    end
  end
end
