require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase do
  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
    @showcase = Atrium::Showcase.new(:atrium_exhibit_id=>@exhibit.id)
    @showcase.save
  end

  after(:each) do
    @showcase.delete
    @exhibit.delete
    begin
      @item.delete
    rescue
    end
    begin
      @fail_showcase.delete
    rescue 
    end
    begin
      @showcase2.delete
    rescue
    end
    begin
      @exhibit2.delete
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
        @showcase.featured_items.create
        @showcase.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create featured item in nested create" do
      @item = @showcase.featured_items.create(:solr_doc_id=>"ns:46")
      @showcase.featured_items.should == [@item]
      @showcase.featured_items.first.solr_doc_id.should == "ns:46"
      @showcase.featured_items.first.type.should == "Atrium::Showcase::Item::Featured"
    end

    it "should be able to delete an existing featured item" do
      @item = @showcase.featured_items.create(:solr_doc_id=>"ns:46")
      @showcase.save
      @showcase.update_attributes({:featured_items_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @showcase.featured_items.first.marked_for_destruction?.should == true
      @showcase.save!
      @showcase.reload.featured_items.size.should == 0
    end
  end

  describe "#related_items" do
    it "should throw exception if try to create without solr_doc_id" do
      threw_exception = false
      begin
        @showcase.related_items.create
        @showcase.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create related item in nested create" do
      @item = @showcase.related_items.create(:solr_doc_id=>"ns:46")
      @showcase.save!
      @showcase.related_items.should == [@item]
      @showcase.related_items.first.solr_doc_id.should == "ns:46"
      @showcase.related_items.first.type.should == "Atrium::Showcase::Item::Related"
    end

    it "should be able to delete an existing related item" do
      @item = @showcase.related_items.create(:solr_doc_id=>"ns:46")
      @showcase.save
      @showcase.update_attributes({:related_items_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @showcase.related_items.first.marked_for_destruction?.should == true
      @showcase.save!
      @showcase.reload.related_items.size.should == 0
    end
  end

  describe "#descriptions" do
    it "should throw exception if try to create without solr_doc_id" do
      threw_exception = false
      begin
        @showcase.descriptions.create
        @showcase.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
    
    it "should be able to create description in nested create" do
      @item = @showcase.descriptions.create(:solr_doc_id=>"ns:46")
      @showcase.descriptions.should == [@item]
      @showcase.descriptions.first.solr_doc_id.should == "ns:46"
      @showcase.descriptions.first.type.should == "Atrium::Showcase::Item::Description"
    end

    it "should be able to delete an existing description" do
      @item = @showcase.descriptions.create(:solr_doc_id=>"ns:46")
      @showcase.save
      @showcase.update_attributes({:descriptions_attributes => [{:id => @item.id, :_destroy => '1'}]})
      @showcase.descriptions.first.marked_for_destruction?.should == true
      @showcase.save!
      @showcase.reload.descriptions.size.should == 0
    end
  end

  describe "#exhibit" do
    it "should return correct exhibit" do
      @showcase.exhibit.should == @exhibit
    end

    it "should throw an exception if exhibit not set" do
      @fail_showcase = Atrium::Showcase.new
      threw_exception = false
      begin
        @fail_showcase.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
    end
  end

  describe "#facet_selections" do
    it "should allow no facet selection if looking at top level" do
      @showcase.facet_selections.size.should == 0
      @showcase.save!
      #it will throw an exception if this does not work
    end

    it "should only allow setting showcase facet selection associated with facets that are defined within exhibit" do
       threw_exception = false
      begin
        @facet_selection2 = @showcase.facet_selections.create({:solr_facet_name=>"my_facet2"})
        @showcase.save!
      rescue
        threw_exception = true
      end
      threw_exception.should == true
      false.should == true
    end

    it "should be able to set the facet selection for a showcase" do
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"}) 
      @showcase.save!
      @showcase.facet_selections.should == [@facet_selection]
    end
  end

  describe "#initialize" do
    it "should allow no facet selections defined" do
      @showcase = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
      @showcase.save!
      @showcase.facet_selections.should == []
    end
  end
end
