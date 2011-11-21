require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Atrium::CollectionsHelper do

  before(:each) do
    @collection = Atrium::Collection.new
  end

  after(:each) do
    begin
      @collection.delete
    rescue
    end
  end
  describe "get_collections_list" do
    it "should call find with all on Atrium::Collection class" do
      Atrium::Collection.expects(:find).with(:all)
      helper.get_collections_list
    end
  end

  describe "edit_collection_link" do
    it "should return properly formatted edit collection link" do
      helper.stubs(:params).returns({:controller=>"atrium_collections", :id=>"my_collection_id"})
      helper.edit_collection_link.should == "/atrium_collections/my_collection_id/edit?render_search=false"
      helper.stubs(:params).returns({:collection_id=>"my_collection_id"})
      helper.edit_collection_link.should == "/atrium_collections/my_collection_id/edit?render_search=false"
      helper.edit_collection_link("my_class").should == "/atrium_collections/my_collection_id/edit?class=my_class&render_search=false"
    end
  end

  describe "browse_collection_link" do
    it "should return properly formatted browse collection link" do
      helper.stubs(:params).returns({:controller=>"atrium_collections",:id=>"my_collection_id"})
      helper.browse_collection_link.should == "/atrium_collections/my_collection_id"
      helper.stubs(:params).returns({:collection_id=>"my_collection_id"})
      helper.browse_collection_link.should == "/atrium_collections/my_collection_id"
    end
  end

  describe "add_browse_facet_params" do
    it "should return a params hash with a field pointing to an array with the new value" do
      p = HashWithIndifferentAccess.new
      helper.add_browse_facet_params(:test, "testing", p).should == {"f"=>{"test"=>["testing"]}}
      #test if p is nil
      helper.add_browse_facet_params(:test, "testing").should == {"f"=>{"test"=>["testing"]}}
    end
  end

  describe "get_browse_facet_path" do
    before do
      catalog_facet_params = HashWithIndifferentAccess.new({:q => "query",
                :search_field => "search_field",
                :f => {"facet_field_1" => ["value1"], "facet_field_2" => ["value2", "value2a"]},
                :collection_id => 'collection_PID',
                :controller => "catalog"
      })
      helper.stubs(:params).returns(catalog_facet_params)
    end
    it "should redirect to collection action" do
      response = helper.get_browse_facet_path("facet_solr_field", "item_value", ["facet_field_1","facet_field_2"], "1")
      response.should == "/atrium_collections/collection_PID?class=browse_facet_select&collection_id=collection_PID&f[facet_field_1][]=value1&f[facet_field_2][]=value2&f[facet_field_2][]=value2a&f[facet_solr_field][]=item_value&showcase_number=1"
    end

    it "if an item is selected and generating a path for alternate selection at the same level then the path should not include any child facet selections that may exist" do
      catalog_facet_params = {:q => "query",
                :search_field => "search_field",
                :f => {"facet_field_1" => ["value1"], "facet_field_2" => ["value2a"]},
                :collection_id => 'collection_PID',
                :controller => "catalog"
      }
      helper.stubs(:params).returns(catalog_facet_params)
      # browse level data to work with.....
      # browse_level_data = [{:solr_facet_name=>"facet_field_1",:label=>"my_label",:selected=>"value1",:values=>["value1","value1a","value1b"]},
      #                     {:solr_facet_name=>"facet_field_2",:label=>"my_label2",:selected=>"value2a",:values=>["value2","value2a"]}]
      #test making link for something not currently selected that should have child facet selection removed
      browse_facets = ["facet_field_1","facet_field_2"]
      helper.get_browse_facet_path("facet_field_1","value1a",browse_facets,"1").should == "/atrium_collections/collection_PID?class=browse_facet_select&collection_id=collection_PID&f[facet_field_1][]=value1a&showcase_number=1"
    end
  end

  describe "get_selected_browse_facet_path" do
    before do
      @catalog_facet_params = {
                :f => {"facet_field_1" => ["value1"], "facet_field_2" => ["value2", "value2a"]},
                :id => 'collection_PID',
                :controller => "atrium_collections",
                 :action=>"show"
      }
      helper.stubs(:params).returns(@catalog_facet_params)
    end
    it "should redirect to collection action" do
      helper.stubs(:params).returns(@catalog_facet_params)
      item = {"facet_field" => ["facet_value"]}
      item.stubs(:value).returns(["value1"])
      #helper.stubs(:remove_facet_params).returns({"f" => {"facet_field_1" => ["value1"], "facet_field_2" => ["value2", "value2a"]},
      #          "id" => 'collection_PID',
      #          "controller" => "atrium_collections"
      #})      
      response = helper.get_selected_browse_facet_path("facet_field_1", item, ["facet_field_1", "browse_facet"],"1")
      #all browse facets should be removed since at the top, and the only current facet in the params is facet_field_1, so facet_field_2 stays
      response.should == "/atrium_collections/collection_PID?collection_id=collection_PID&f[facet_field_2][]=value2&f[facet_field_2][]=value2a&showcase_number=1"
    end
  end

  describe "get_selected_browse_facets" do
    before do
      @catalog_facet_params = {
                :f => {"facet_field_1" => ["value1"], "facet_field_2" => ["value2", "value2a"]},
                :id => 'collection_PID',
                :controller => "atrium_collections",
                 :action=>"show"
      }
      helper.stubs(:params).returns(@catalog_facet_params)
    end
    it "should return a hash of selected facet mapped to value not in array" do
      browse_facets = ["facet_field_1","facet_field_2","facet_field_3"]
      helper.get_selected_browse_facets(browse_facets).should == {:facet_field_1=>"value1",:facet_field_2=>"value2"}
    end
  end

  describe "remove_related_facet_params" do
    before(:each) do
      @params = {
                :f => {:facet_field_1 => ["value1"], :facet_field_2 => ["value2"], :facet_field_4=>["value4"]}
      }
      @browse_facets = [:facet_field_1,:facet_field_2,:facet_field_3]
      helper.stubs(:params).returns(@params)
    end
    it "should return a params hash with a selected facet field removed" do
      helper.remove_related_facet_params(:facet_field_2,@params,@browse_facets,"1").should == {:f=>{:facet_field_1 => ["value1"],:facet_field_4=>["value4"]}}
    end

     it "should remove any lower selected facets if parent facet is removed" do
      helper.remove_related_facet_params(:facet_field_1,@params,@browse_facets,"1").should == {:f=>{:facet_field_4=>["value4"]}}
    end

    it "should ignore one that is not a browse facet" do
      helper.remove_related_facet_params(:facet_field_4,@params,@browse_facets,"1").should == {:f=>{:facet_field_1 => ["value1"], :facet_field_2 => ["value2"], :facet_field_4=>["value4"]}}
    end
  end

end
