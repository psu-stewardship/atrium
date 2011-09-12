require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Blacklight::SolrHelper.stubs(:class_inheritable_accessor)

describe Atrium::SolrHelper do

  before(:each) do
    @exhibit = Atrium::Exhibit.new
    @exhibit.save
  end

  after(:each) do
    begin
      @exhibit.delete
    rescue
    end
    begin
      @browse_set.delete
    rescue
    end
  end

  describe "initialize_exhibit" do
    it "atrium_exhibit should be nil if both :id (if atrium_exhibits controller) and :exhibit_id not in params" do
      helper.stubs(:params).returns({:id=>"test_id"})
      helper.initialize_exhibit
      helper.atrium_exhibit.should == nil
      helper.stubs(:params).returns({:controller=>"atrium_exhibits",:exhibit_id=>"test_id"})
      helper.atrium_exhibit.should == nil
      puts "here"
    end

    it "should raise an exception if the exhibit_id passed in does not exist" do
      helper.expects(:params).returns({:id=>"test_id",:controller=>"atrium_exhibits"}).at_least_once
      #these only get called once if an exhibit is found
      helper.expects(:build_lucene_query).returns("_query_:id\:test_id")
      helper.expects(:get_search_results)
      @exhibit.save!
      logger.expects(:error).once
      helper.initialize_exhibit
      #check valid case as well
      helper.expects(:params).returns({:id=>@exhibit.id,:controller=>"atrium_exhibits"}).at_least_once
      helper.initialize_exhibit
    end

    it "should call get_search_results with correct params and query and all variables initialized correctly" do
      helper.expects(:params).returns({:id=>"test_id",:controller=>"atrium_exhibits"}).at_least_once
      @exhibit.expects(:id).returns("test_id").at_least(0)
      @exhibit.expects(:browse_sets).returns(["test","test1"])
      @exhibit.expects(:build_members_query).returns("_query_:id\:namespace").at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      helper.expects(:build_lucene_query).returns("_query_:id\:test_id").at_least_once
      helper.expects(:get_search_results)
      helper.initialize_exhibit
      helper.atrium_exhibit.should == @exhibit
      helper.stubs(:params).returns({:exhibit_id=>"test_id"})
      @exhibit.stubs(:id).returns("test_id")
      @exhibit.expects(:browse_sets).returns(["test","test1"]).at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      response = mock()
      document_list = mock()
      helper.expects(:get_search_results).with({:exhibit_id=>"test_id"},{:q=>"_query_:id\:test_id AND _query_:id\:namespace"}).returns([response,document_list])
      helper.initialize_exhibit
      helper.atrium_exhibit.should == @exhibit
      helper.browse_sets.should == @exhibit.browse_sets
      helper.extra_controller_params.should == {:q=>"_query_:id\:test_id AND _query_:id\:namespace"}
      helper.browse_response.should == response
      helper.browse_document_list.should == document_list
    end
  end

  describe "get_browse_level_navigation_data" do
    it "should call initialize_exhibit only if @atrium_exhibit is nil" do
      helper.expects(:initialize_exhibit).times(1)
      #it should not do anything here as the @atrium_exhibit object will still be nil
      helper.get_browse_level_navigation_data
      #it should not call initialize_exhibit if it is not nil, but should go no further since browse sets will be empty
      exhibit = mock()
      exhibit.expects(:browse_sets).returns(nil)
      helper.stubs(:atrium_exhibit).returns(exhibit)
      helper.get_browse_level_navigation_data
    end

    it "if atrium exhibit still nil after calling initialize exhibit than should return empty array" do
      helper.expects(:params).returns({:exhibit_id=>"test_id"}).at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(nil)
      helper.expects(:get_browse_level_data).times(0)
      helper.get_browse_level_navigation_data.should == []
    end

    it "if no atrium exhibit browse_sets it should return an empty array" do
      exhibit = mock()
      exhibit.stubs(:browse_sets).returns([])
      helper.stubs(:atrium_exhibit).returns(exhibit)
      helper.get_browse_level_navigation_data.should == []
    end

    it "if atrium exhibit is not nil and has browse sets it should call get browse level data for each browse set" do
      exhibit = Atrium::Exhibit.new
      exhibit.save
      exhibit.stubs(:browse_sets).returns([])
      helper.stubs(:atrium_exhibit).returns(exhibit)
      browse_set1 = Atrium::BrowseSet.new({:atrium_exhibit_id=>exhibit.id,:set_number=>1})
      browse_set1.save
      browse_set2 = Atrium::BrowseSet.new({:atrium_exhibit_id=>exhibit.id,:set_number=>2})
      browse_set2.save
      browse_level1 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>browse_set1.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>browse_set2.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      browse_level3 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>browse_set2.id,:solr_facet_name=>"my_facet3",:label=>"my_label3"})
      browse_set1.stubs(:browse_levels).returns([browse_level1])
      browse_set2.stubs(:browse_levels).returns([browse_level2,browse_level3])
      exhibit.expects(:browse_sets).returns([browse_set1,browse_set2]).at_least_once
      browse_response = mock()
      helper.stubs(:browse_response).returns(browse_response)
      extra_con_params = mock()
      helper.stubs(:extra_controller_params).returns(extra_con_params)
      updated_browse_level1 = browse_level1.clone
      updated_browse_level1.expects(:values).returns(["test1","test2"])
      updated_browse_level1.expects(:selected).returns("test1")
      updated_browse_level2 = browse_level2.clone
      updated_browse_level2.expects(:values).returns(["test3","test4"])
      helper.expects(:get_browse_level_data).with([browse_level1],browse_response,extra_con_params).returns([updated_browse_level1])
      helper.expects(:get_browse_level_data).with([browse_level2,browse_level3],browse_response,extra_con_params).returns([updated_browse_level2,browse_level3])
      #check that the array returned is flattened appropriately on concat
      browse_data = helper.get_browse_level_navigation_data
      browse_data.size.should == 2
      #order is important here for both browse sets and esp. nested levels
      browse_data.first.should == browse_set1
      browse_data.second.should == browse_set2
      browse_data.first.browse_levels.should == [updated_browse_level1]
      browse_data.second.browse_levels.should == [updated_browse_level2,browse_level3]
      browse_data.first.browse_levels.first.values.should == ["test1","test2"]
      browse_data.first.browse_levels.first.selected.should == "test1"
      browse_data.second.browse_levels.first.values.should == ["test3","test4"]
      browse_data.second.browse_levels.first.selected.should == nil
      #for the other browse level of the second browse set values should be empty since nothing selected in parent
      browse_data.second.browse_levels.second.values.should == []
    end
  end

  describe "get_browse_level_data" do
    #since this method is private need to do a few things to make sure it gets called by get_browse_level_navigation_data
=begin
    before(:each) do
      @exhibit.save
      Atrium::Exhibit.expects(:find).returns(@exhibit).at_least_once
      @response = mock()
      @document_list = mock()
      helper.stubs(:params).returns({:exhibit_id=>@exhibit.id})
      helper.expects(:build_lucene_query).at_least_once
      helper.expects(:get_search_results).returns([@response,@document_list]).at_least_once
    end
=end

    it "if browse sets not defined it should return an empty array" do
      helper.get_browse_level_navigation_data.should == []
      @exhibit.browse_sets.should == []
    end

    it "should return an array of browse set objects with browse levels objects sorted by level number if any defined" do
      @browse_set = Atrium::BrowseSet.new({:atrium_exhibit_id=>@exhibit.id,:set_number=>1})
      @browse_set.save
      @browse_set2 = Atrium::BrowseSet.new({:atrium_exhibit_id=>@exhibit.id,:set_number=>2})
      @browse_set2.save
      helper.expects(:facet_field_labels).returns("my_label").times(3)
      #label will be nil
      browse_level1 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet", :level_number=>1})
      browse_level1.save
      browse_level2 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet2", :level_number=>2})
      browse_level2.save
      @browse_set.stubs(:browse_levels).returns([browse_level1,browse_level2])
      browse_level3 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set2.id,:solr_facet_name=>"my_facet2", :level_number=>1})
      browse_level3.save
      browse_level4 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set2.id,:solr_facet_name=>"my_facet3", :level_number=>2})
      browse_level4.save
      @browse_set2.stubs(:browse_levels).returns([browse_level3,browse_level4])
      @exhibit.expects(:browse_sets).returns([@browse_set,@browse_set2]).at_least_once
      helper.expects(:atrium_exhibit).returns(@exhibit).at_least_once
      
      browse_response = mock()
      facet1 = mock()
      facet2 = mock()
      facet3 = mock()
      item1 = mock()
      item2 = mock()
      item3 = mock()
      item4 = mock()
      item5 = mock()
      
      item1.expects(:value).returns("val1").at_least_once
      item2.expects(:value).returns("val2").at_least_once
      item3.expects(:value).returns("val3").at_least_once
      item4.expects(:value).returns("val4").at_least_once
      item5.expects(:value).returns("val5").at_least_once

      facet1.expects(:items).returns([item1,item2]).at_least_once
      facet1.expects(:name).returns("my_facet").at_least_once
      facet2.expects(:items).returns([item3,item4,item5]).at_least_once
      facet2.expects(:name).returns("my_facet2").at_least_once
      browse_response.expects(:facets).returns([facet1,facet2,facet3]).at_least_once
      helper.stubs(:browse_response).returns(browse_response)
      helper.expects(:facet_in_params?).returns(false).at_least_once
      helper.expects(:facet_in_params?).with('my_facet','val2').returns(true)
      

      browse_data = helper.get_browse_level_navigation_data
      browse_data.size.should == 2
      browse_data.first.should == @browse_set
      browse_data.second.should == @browse_set2

      browse_data.first.browse_levels.first.should == browse_level1
      browse_data.first.browse_levels.second.should == browse_level2
      browse_data.second.browse_levels.first.should == browse_level3
      browse_data.second.browse_levels.second.should == browse_level4

      browse_data.first.browse_levels.first.values.should == ["val1","val2"]
      browse_data.first.browse_levels.second.values.should == ["val3","val4","val5"]
      browse_data.second.browse_levels.first.values.should == ["val3","val4","val5"]
      browse_data.second.browse_levels.second.values.should == []

      browse_data.first.browse_levels.first.selected.should == "val2"
      browse_data.first.browse_levels.second.selected.should == nil
      browse_data.second.browse_levels.first.selected.should == nil
      browse_data.second.browse_levels.second.selected.should == nil
    end

    it "should use the blacklight facet field label if no label defined in a browse level" do
      @exhibit.save
      @browse_set = Atrium::BrowseSet.new({:atrium_exhibit_id=>@exhibit.id,:set_number=>1})
      @browse_set.save
      @exhibit.expects(:browse_sets).returns([@browse_set]).at_least_once
      helper.expects(:facet_field_labels).returns("my_label").twice()
      #label will be nil
      browse_level = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet"})
      @browse_set.browse_levels << browse_level
      facet = mock()
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      facet.expects(:items).returns([item]).at_least_once
      facet.expects(:name).returns("my_facet").at_least_once
      browse_response = mock()
      browse_response.expects(:facets).returns([facet]).at_least_once
      helper.expects(:browse_response).returns(browse_response)
      helper.expects(:facet_in_params?).returns(false)
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val"]}]
      #check if label is blank instead
      browse_level.label = ""
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val"]}]
    end

    it "should use the label in a browse level if defined" do
      helper.expects(:facet_field_labels).returns("my_label").times(0)
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label_2"})
      @exhibit.browse_levels << browse_level
      facet = mock()
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      facet.expects(:items).returns([item]).at_least_once
      facet.expects(:name).returns("my_facet").at_least_once
      @response.expects(:facets).returns([facet]).at_least_once
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label_2",:values=>["my_val"]}]
    end

    it "if no f param is defined it should set the response without f param to be response" do
      #if they are the same then response.facets should be called twice
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      @exhibit.browse_levels << browse_level
      @facet = mock()
      @facet.expects(:name).returns("other_facet").at_least_once
      @response.expects(:facets).returns([@facet]).twice
      helper.get_browse_level_navigation_data
    end

    it "should return browse navigation hash with values filled in if a browse facet exists and f param not defined (nothing selected)" do
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      @exhibit.browse_levels << browse_level
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once
      @response.expects(:facets).returns([facet]).twice
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"]}]
    end

    it "if f param is defined it should make the value provided as selected and return a second browse level of data in results if more than one level defined" do
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      @exhibit.browse_levels << browse_level
      @exhibit.browse_levels << browse_level2
      helper.expects(:params).returns({:exhibit_id=>@exhibit.id,:f=>{"my_facet"=>["my_val2"]}}).at_least_once
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once
      facet2 = mock()
      facet2.expects(:name).returns("my_facet2").at_least_once
      item3 = mock()
      item3.expects(:value).returns("my_val3").at_least_once
      item4 = mock()
      item4.expects(:value).returns("my_val4").at_least_once
      facet2.expects(:items).returns([item3,item4]).at_least_once
      @response.expects(:facets).returns([facet2,facet]).at_least_once
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"],:selected=>"my_val2"},
                                                         {:solr_facet_name=>"my_facet2", :label=>"my_label2", :values=>["my_val3","my_val4"]}]
    end

    it "if multiple browse levels defined and f defined but nothing selected it should only return a browse level element for top level" do
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      @exhibit.browse_levels << browse_level
      @exhibit.browse_levels << browse_level2
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once
      facet2 = mock()
      facet2.expects(:name).returns("my_facet2").at_least_once
      @response.expects(:facets).returns([facet2,facet]).at_least_once
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"]}]
    end

    it "if 3 browse levels defined and two items selected in each browse level then it should return 3 browse levels" do
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      browse_level3 = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet3",:label=>"my_label3"})
      @exhibit.browse_levels << browse_level
      @exhibit.browse_levels << browse_level2
      @exhibit.browse_levels << browse_level3
      helper.expects(:params).returns({:exhibit_id=>@exhibit.id,:f=>{"my_facet"=>["my_val2"],"my_facet2"=>"my_val3"}}).at_least_once
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once

      facet2 = mock()
      facet2.expects(:name).returns("my_facet2").at_least_once
      item3 = mock()
      item3.expects(:value).returns("my_val3").at_least_once
      item4 = mock()
      item4.expects(:value).returns("my_val4").at_least_once
      facet2.expects(:items).returns([item3,item4]).at_least_once

      facet3 = mock()
      facet3.expects(:name).returns("my_facet3").at_least_once
      item5 = mock()
      item5.expects(:value).returns("my_val5").at_least_once
      item6 = mock()
      item6.expects(:value).returns("my_val6").at_least_once
      facet3.expects(:items).returns([item5,item6]).at_least_once

      @response.expects(:facets).returns([facet2,facet,facet3]).at_least_once
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"],:selected=>"my_val2"},
                                                         {:solr_facet_name=>"my_facet2", :label=>"my_label2", :values=>["my_val3","my_val4"], :selected=>"my_val3"},{:solr_facet_name=>"my_facet3", :label=>"my_label3", :values=>["my_val5","my_val6"]}] 
    end

    it "should ignore a facet that is not present" do
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      @exhibit.browse_levels << browse_level
      @exhibit.browse_levels << browse_level2
      helper.expects(:params).returns({:exhibit_id=>@exhibit.id,:f=>{"my_facet"=>["my_val2"],"my_facet2"=>"my_val3"}}).at_least_once
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once

      @response.expects(:facets).returns([facet]).at_least_once
      #second level facet not present so it should only return one level even though first level has something selected
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"],:selected=>"my_val2"}] 
    end

    it "if 2 browse levels defined and two items selected it should handle having something selected at the lowest browse level" do
      @browse_set = Atrium::BrowseSet.new(:atrium_exhibit_id=>@exhibit.id,:set_number=>1)
      @browse_set.save
      browse_level = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet",:label=>"my_label"})
      browse_level2 = Atrium::BrowseLevel.new({:atrium_browse_set_id=>@browse_set.id,:solr_facet_name=>"my_facet2",:label=>"my_label2"})
      @browse_set.browse_levels << browse_level
      @browse_set.browse_levels << browse_level2
      helper.expects(:params).returns({:exhibit_id=>@exhibit.id,:f=>{"my_facet"=>["my_val2"],"my_facet2"=>"my_val3"}}).at_least_once
      facet = mock()
      facet.expects(:name).returns("my_facet").at_least_once
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      item2 = mock()
      item2.expects(:value).returns("my_val2").at_least_once
      facet.expects(:items).returns([item,item2]).at_least_once
      facet2 = mock()
      facet2.expects(:name).returns("my_facet2").at_least_once
      item3 = mock()
      item3.expects(:value).returns("my_val3").at_least_once
      item4 = mock()
      item4.expects(:value).returns("my_val4").at_least_once
      facet2.expects(:items).returns([item3,item4]).at_least_once
      @response.expects(:facets).returns([facet2,facet]).at_least_once
      helper.get_browse_level_navigation_data.should == [{:solr_facet_name=>"my_facet",:label=>"my_label",:values=>["my_val","my_val2"],:selected=>"my_val2"},
                                                         {:solr_facet_name=>"my_facet2", :label=>"my_label2", :values=>["my_val3","my_val4"], :selected=>"my_val3"}]
    end
  end
end
