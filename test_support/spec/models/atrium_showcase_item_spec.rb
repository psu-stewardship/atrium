require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase::Item do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save!
    @showcase = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
    @showcase.save!
    @item = Atrium::Showcase::Item.new({:atrium_showcase_id=>@showcase.id})
    @item.save
  end

  after(:each) do
    @showcase.delete
    @item.delete
    @exhibit.delete
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

  describe "#solr_doc_id" do
    it "solr_doc_id cannot be null" do
      begin
        @item.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should return correct solr doc id" do
      @item.solr_doc_id = "ns:10"
      @item.solr_doc_id.should == "ns:10"
    end
  end

  describe "#showcase" do
    it "showcase cannot be null" do
      @fail_item = Atrium::Showcase::Item.new({:solr_doc_id=>"ns:20"})
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
