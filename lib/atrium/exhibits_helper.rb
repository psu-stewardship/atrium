# This module provides exhibit helper methods for views in Atrium
#  Will be included in Blacklight Catalog classes (i.e CatalogController) to add Atrium functions
module Atrium::ExhibitsHelper
  def get_exhibits_list
    Atrium::Exhibit.find(:all)
  end

  def edit_and_browse_exhibit_links(exhibit)
    result = ""
    if params[:action] == "edit" || params[:action] == "update"
      result << "<a href=\"#{atrium_exhibit_path(params[:exhibit_id])}\" class=\"browse toggle\">View</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">View</span>"
      result << "<a href=\"#{edit_atrium_exhibit_path(params[:id], :class => "edit_exhibit", :render_search=>"false")}\" class=\"edit toggle\">Edit</a>"
    end
    return result
  end
end
