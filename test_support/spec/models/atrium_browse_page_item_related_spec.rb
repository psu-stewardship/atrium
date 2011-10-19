require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowsePage::Item::Related do
  before(:each) do
    @browse_page = Atrium::BrowsePage.new
    @browse_page.save
    @item = Atrium::BrowsePage::Item::Related.new({:atrium_browse_page_id=>@browse_page.id})
    @item.save
  end

  after(:each) do
    @item.delete
    @browse_page.delete
  end

  describe "#type" do
    it "should return type Atrium::BrowsePage::Item::Related" do
      @item.type.should == "Atrium::BrowsePage::Item::Related"
    end
  end
end
