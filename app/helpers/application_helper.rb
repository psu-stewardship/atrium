
require 'cgi'

module ApplicationHelper

  def thumbnail_class( document )
    display_thumnail( document ) ? ' with-thumbnail' : ''
  end

  def top_level_browse_page(showcase_id)
    browse_pages = Atrium::BrowsePage.find_by_atrium_showcase_id(showcase_id)
    browse_page = browse_pages.first unless browse_pages.empty?
  end
end

