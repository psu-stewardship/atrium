require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowsePage::Item::Description do
  before(:each) do
    @browsepage = Atrium::BrowsePage.new
    @browsepage.save
    @item = Atrium::BrowsePage::Item::Description.new({:atrium_browse_page_id=>@browsepage.id})
    @item.save
  end

  after(:each) do
    @item.delete
    @browsepage.delete
  end

  describe "#type" do
    it "should return type Atrium::BrowsePage::Item::Description" do
      @item.type.should == "Atrium::BrowsePage::Item::Description"
    end
  end
end
