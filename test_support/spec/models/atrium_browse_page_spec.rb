require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::BrowsePage do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @showcase = Atrium::Showcase.new(:atrium_exhibit_id=>@exhibit.id,:set_number=>1)
    @showcase.save
    @browse_page = Atrium::BrowsePage.new(:atrium_showcase_id=>@showcase.id)
    @browse_page.save
  end

  after(:each) do
    @browse_page.delete
    @showcase.delete
    @exhibit.delete
    begin
      @item.delete
    rescue
    end
    begin
      @fail_browse_page.delete
    rescue 
    end
    begin
      @browse_page2.delete
    rescue
    end
    begin
      @facet_selection.delete
    rescue
    end
    begin
      @facet_selection2.delete
    rescue
    end
  end

  describe "#featured_items" do
    it "should throw exception if try to create without solr_doc_id" do
      threw_exception = false
      begin
        @browse_page.featured_items.create
        @browse_page.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create featured item in nested create" do
      @item = @browse_page.featured_items.create(:solr_doc_id=>"ns:46")
      @browse_page.featured_items.should == [@item]
      @browse_page.featured_items.first.solr_doc_id.should == "ns:46"
      @browse_page.featured_items.first.type.should == "Atrium::BrowsePage::Item::Featured"
    end

    it "should be able to delete an existing featured item" do
      @item = @browse_page.featured_items.create(:solr_doc_id=>"ns:46")
      @browse_page.save
      @browse_page.update_attributes({:featured_items_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @browse_page.featured_items.first.marked_for_destruction?.should == true
      @browse_page.save!
      @browse_page.reload.featured_items.size.should == 0
    end
  end

  describe "#related_items" do
    it "should throw exception if try to create without solr_doc_id" do
      threw_exception = false
      begin
        @browse_page.related_items.create
        @browse_page.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create related item in nested create" do
      @item = @browse_page.related_items.create(:solr_doc_id=>"ns:46")
      @browse_page.save!
      @browse_page.related_items.should == [@item]
      @browse_page.related_items.first.solr_doc_id.should == "ns:46"
      @browse_page.related_items.first.type.should == "Atrium::BrowsePage::Item::Related"
    end

    it "should be able to delete an existing related item" do
      @item = @browse_page.related_items.create(:solr_doc_id=>"ns:46")
      @browse_page.save
      @browse_page.update_attributes({:related_items_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @browse_page.related_items.first.marked_for_destruction?.should == true
      @browse_page.save!
      @browse_page.reload.related_items.size.should == 0
    end
  end

  describe "#descriptions" do
    it "should throw exception if try to create without solr_doc_id" do
      threw_exception = false
      begin
        @browse_page.descriptions.create
        @browse_page.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create description in nested create" do
      @item = @browse_page.descriptions.create(:solr_doc_id=>"ns:46")
      @browse_page.descriptions.should == [@item]
      @browse_page.descriptions.first.solr_doc_id.should == "ns:46"
      @browse_page.descriptions.first.type.should == "Atrium::BrowsePage::Item::Description"
    end

    it "should be able to delete an existing description" do
      @item = @browse_page.descriptions.create(:solr_doc_id=>"ns:46")
      @browse_page.save
      @browse_page.update_attributes({:descriptions_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @browse_page.descriptions.first.marked_for_destruction?.should == true
      @browse_page.save!
      @browse_page.reload.descriptions.size.should == 0
    end
  end

  describe "#showcase" do
    it "should return correct showcase" do
      @browse_page.showcase.should == @showcase
    end

    it "should throw an exception if exhibit not set" do
      @fail_browse_page = Atrium::BrowsePage.new
      threw_exception = false
      begin
        @fail_browse_page.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
  end

  describe "#facet_selections" do
    it "should allow no facet selection if looking at top level" do
      @browse_page.facet_selections.size.should == 0
      @browse_page.save!
      #it will throw an exception if this does not work
    end

    it "should only allow setting browse_page facet selection associated with facets that are defined within exhibit" do
       threw_exception = false
      begin
        @facet_selection2 = @browse_page.facet_selections.create({:solr_facet_name=>"my_facet2"})
        @browse_page.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
      false.should == true
    end

    it "should be able to set the facet selection for a browse page" do
      @facet_selection = @browse_page.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"}) 
      @browse_page.save!
      @browse_page.facet_selections.should == [@facet_selection]
    end
  end

  describe "#initialize" do
    it "should allow no facet selections defined" do
      @browse_page = Atrium::BrowsePage.new({:atrium_showcase_id=>@showcase.id})
      @browse_page.save!
      @browse_page.facet_selections.should == []
    end
  end
end
