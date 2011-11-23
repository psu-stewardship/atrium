
require 'cgi'

module ApplicationHelper

  def thumbnail_class( document )
    display_thumnail( document ) ? ' with-thumbnail' : ''
  end

  def top_level_showcase(exhibit_id)
    showcases = Atrium::Showcase.find_by_atrium_exhibit_id(exhibit_id)
    showcase = showcases.first unless showcases.empty?
  end
end

