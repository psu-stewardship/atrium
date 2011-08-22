require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Blacklight::SolrHelper.stubs(:class_inheritable_accessor)

describe Atrium::SolrHelper do

  before(:each) do
    @exhibit = Atrium::Exhibit.new
  end

  after(:each) do
    begin
      @exhibit.delete
    rescue
    end
  end

  describe "add_facet_params" do
    it "should return a params hash with a field pointing to an array with the new value" do
      helper.expects(:params).returns({:f=>{:test=>["first_val"]}})
      p = {}
      helper.add_facet_params(:test, "testing", p).should == {:f=>{:test=>["testing"]}}
      #test if p is nil
      helper.add_facet_params(:test, "testing").should == {:f=>{:test=>["first_val","testing"]}}
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
      @exhibit.expects(:browse_levels).returns(["test","test1"])
      @exhibit.expects(:build_members_query).returns("_query_:id\:namespace").at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      helper.expects(:build_lucene_query).returns("_query_:id\:test_id").at_least_once
      helper.expects(:get_search_results)
      helper.initialize_exhibit
      helper.atrium_exhibit.should == @exhibit
      helper.stubs(:params).returns({:exhibit_id=>"test_id"})
      @exhibit.stubs(:id).returns("test_id")
      @exhibit.expects(:browse_levels).returns(["test","test1"]).at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      response = mock()
      document_list = mock()
      helper.expects(:get_search_results).with({:q=>"_query_:id\:test_id AND _query_:id\:namespace"}).returns([response,document_list])
      helper.initialize_exhibit
      helper.atrium_exhibit.should == @exhibit
      helper.browse_levels.should == @exhibit.browse_levels
      helper.extra_controller_params.should == {:q=>"_query_:id\:test_id AND _query_:id\:namespace"}
      helper.browse_response.should == response
      helper.browse_document_list.should == document_list
    end
  end

  describe "get_browse_level_navigation_data" do
    it "should call initialize_exhibit only if @atrium_exhibit is nil" do
      #it should only call it the first time
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      helper.expects(:params).returns({:exhibit_id=>"test_id"}).at_least_once
      helper.expects(:build_lucene_query)
      helper.expects(:get_search_results)
      helper.expects(:get_browse_level_data).once
      helper.get_browse_level_navigation_data
      helper.atrium_exhibit.should == @exhibit
      #now should be not call initialize_exhibit if it is not nil
      helper.expects(:initialize_exhibit).times(0)
      helper.expects(:get_browse_level_data).once
      helper.get_browse_level_navigation_data
    end

    it "if atrium exhibit still nil after calling initialize exhibit than should return empty array" do
      helper.expects(:params).returns({:exhibit_id=>"test_id"}).at_least_once
      Atrium::Exhibit.expects(:find).with("test_id").returns(nil)
      helper.expects(:get_browse_level_data).times(0)
      helper.get_browse_level_navigation_data.should == []
    end

    it "if atrium exhibit is not nil it should call get_browse_level_data" do
      Atrium::Exhibit.expects(:find).with("test_id").returns(@exhibit)
      helper.expects(:params).returns({:exhibit_id=>"test_id"}).at_least_once
      helper.expects(:build_lucene_query)
      helper.expects(:get_search_results)
      helper.expects(:get_browse_level_data).once
      helper.get_browse_level_navigation_data
    end
  end

  describe "get_browse_level_data" do
    #since this method is private need to do a few things to make sure it gets called by get_browse_level_navigation_data
    before(:each) do
      @exhibit.save
      Atrium::Exhibit.expects(:find).returns(@exhibit).at_least_once
      @response = mock()
      @document_list = mock()
      helper.stubs(:params).returns({:exhibit_id=>@exhibit.id})
      helper.expects(:build_lucene_query).at_least_once
      helper.expects(:get_search_results).returns([@response,@document_list]).at_least_once
    end

    it "if browse levels not defined it should return an empty array" do
      helper.get_browse_level_navigation_data.should == []
      @exhibit.browse_levels.should == []
    end

    it "should use the blacklight facet field label if no label defined in a browse level" do
      helper.expects(:facet_field_labels).returns("my_label").twice()
      #label will be nil
      browse_level = Atrium::BrowseLevel.new({:atrium_exhibit_id=>@exhibit.id,:solr_facet_name=>"my_facet"})
      @exhibit.browse_levels << browse_level
      facet = mock()
      item = mock()
      item.expects(:value).returns("my_val").at_least_once
      facet.expects(:items).returns([item]).at_least_once
      facet.expects(:name).returns("my_facet").at_least_once
      @response.expects(:facets).returns([facet]).at_least_once
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
