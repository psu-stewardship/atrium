require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::Showcase do
  before(:each) do
    @collection = Atrium::Collection.new
    @collection.save
    @exhibit = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>1)
    @exhibit.save
    @collection_showcase = Atrium::Showcase.new(:showcases_id=>@collection.id, :showcases_type=>@collection.class.name)
    @collection_showcase.save
    @exhibit_showcase = Atrium::Showcase.new(:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name)
    @exhibit_showcase.save
  end

  after(:each) do
    @collection_showcase.delete
    @collection.delete
    @exhibit_showcase.delete
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
    
    it "should be able to add featured item" do
      @showcase = Atrium::Showcase.new(:showcases_id=>@collection.id, :showcases_type=>@collection.class.name)
      @showcase.save!
      @showcase.showcase_items[:type]="featured"
      @showcase.showcase_items[:solr_doc_ids]="item1, item2, item3"
      @showcase.save
      @showcase.showcase_items[:solr_doc_ids].should == "item1, item2, item3"
      @showcase.showcase_items[:solr_doc_ids].split(',').first.should == "item1"
    end
  end

  describe "#parent" do
    it "should return correct parent" do
      @exhibit_showcase.parent.should == @exhibit
    end
  end

  describe "#initialize" do
    it "should allow no facet selections defined" do
      @collection = Atrium::Collection.new
      @collection.save
      @showcase = Atrium::Showcase.new(:showcases_id=>@collection.id, :showcases_type=>@collection.class.name)
      @showcase.save!
      @showcase.facet_selections.should == []
    end
  end

  describe "#with_selected_facets" do
    it "should return correct showcase with no facets selected" do
      @showcase2 = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      Atrium::Showcase.with_selected_facets(@exhibit.id).first.should == @showcase
    end

    it "should return correct showcase with one facet selected" do
      @showcase = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase.save!
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @showcase.save!
      Atrium::Showcase.with_selected_facets(@exhibit.id, @exhibit.class.name, {@facet_selection.solr_facet_name=>@facet_selection.value}).first.should == @showcase
    end
    
    it "should return correct showcase with one facet selected but a showcase exists with same facet plus another" do
      @showcase = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase.save!
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @showcase.save!
      @showcase2 = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      Atrium::Showcase.with_selected_facets(@exhibit.id, @exhibit.class.name, {@facet_selection.solr_facet_name=>@facet_selection.value}).first.should == @showcase
    end

    it "should return correct showcase with two facets selected" do
      @showcase = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase.save!
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @facet_selection2 = @showcase.facet_selections.create({:solr_facet_name=>"my_facet2",:value=>"testing2"})
      @showcase.save!
      Atrium::Showcase.with_selected_facets(@exhibit.id, @exhibit.class.name, {@facet_selection2.solr_facet_name=>@facet_selection2.value,
                                              @facet_selection.solr_facet_name=>@facet_selection.value}).first.should == @showcase
    end

    it "should return correct showcase with same facet selections but different exhibit" do
      @showcase = Atrium::Showcase.new({:showcases_id=>@exhibit.id, :showcases_type=>@exhibit.class.name})
      @showcase.save!
      @facet_selection = @showcase.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      @exhibit2 = Atrium::Exhibit.new(:atrium_collection_id=>@collection.id,:set_number=>2)
      @exhibit2.save!
      @showcase2 = Atrium::Showcase.new({:showcases_id=>@exhibit2.id, :showcases_type=>@exhibit2.class.name})
      @showcase2.save!
      @facet_selection2 = @showcase2.facet_selections.create({:solr_facet_name=>"my_facet",:value=>"testing"})
      Atrium::Showcase.with_selected_facets(@exhibit2.id,@exhibit2.class.name, {@facet_selection2.solr_facet_name=>@facet_selection2.value}).first.should == @showcase2
    end
  end
end
