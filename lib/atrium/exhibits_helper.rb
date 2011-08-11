# This module provides exhibit helper methods for views in Atrium
#  Will be included in Blacklight Catalog classes (i.e CatalogController) to add Atrium functions
module Atrium::ExhibitsHelper
  def get_exhibits_list
    Atrium::Exhibit.find(:all)
    #Exhibit.find_by_solr(:all).hits.map{|result| Exhibit.load_instance_from_solr(result["id"])}
  end
end
