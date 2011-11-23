require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase do
  before(:each) do
    @collection = Atrium::Collection.new
    @collection.save
    @exhibit = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>1)
    @exhibit.save
    @showcase = Atrium::Showcase.new(:atrium_exhibit_id=>@exhibit.id)
    @showcase.save
  end

  after(:each) do
    @showcase.delete
    @exhibit.delete
    @collection.delete
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
      pending "..."
    end

    it "should be able to delete an existing description" do
      pending "..."
    end
  end

  describe "#exhibit" do
    it "should return correct exhibit" do
      @showcase.exhibit.should == @exhibit
    end

    it "should throw an exception if collection not set" do
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

    it "should only allow setting showcase facet selection associated with facets that are defined within collection" do
      pending "..."
    end

    it "should be able to set the facet selection for a browse page" do
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

  describe "#with_selected_facets" do
    it "should return correct browse page with no facets selected" do
      @showcase2 = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      Atrium::Showcase.with_selected_facets(@exhibit.id).first.should == @showcase
    end

    it "should return correct browse page with one facet selected" do
      @showcase = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
      @showcase.save!
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @showcase.save!
      @showcase2 = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
       Atrium::Showcase.with_selected_facets(@exhibit.id,{@facet_selection.solr_facet_name=>@facet_selection.value}).first.should == @showcase
    end
    
    it "should return correct browse page with one facet selected but a browse page exists with same facet plus another" do
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @facet_selection2 = @showcase.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      @showcase.save!
      @showcase2 = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit.id})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      Atrium::Showcase.with_selected_facets(@exhibit.id,{@facet_selection2.solr_facet_name=>@facet_selection2.value}).first.should == @showcase2
    end

    it "should return correct browse page with two facets selected" do
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @facet_selection2 = @showcase.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      @showcase.save!
      Atrium::Showcase.with_selected_facets(@exhibit.id,{@facet_selection2.solr_facet_name=>@facet_selection2.value,
                                              @facet_selection.solr_facet_name=>@facet_selection.value}).first.should == @showcase
    end

    it "should return correct browse page with same facet selections but different exhibit" do
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @exhibit2 = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>2)
      @exhibit2.save!
      @showcase2 = Atrium::Showcase.new({:atrium_exhibit_id=>@exhibit2.id})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      Atrium::Showcase.with_selected_facets(@exhibit2.id,{@facet_selection2.solr_facet_name=>@facet_selection2.value}).first.should == @showcase2
    end
  end
end
