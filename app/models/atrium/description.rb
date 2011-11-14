class Atrium::Description < ActiveRecord::Base
  belongs_to :browse_page, :class_name=>'Atrium::BrowsePage', :foreign_key=>"atrium_browse_page_id"

  validates_presence_of  :atrium_browse_page_id

  set_table_name :atrium_descriptions

  def initialize(opts={})
    super
    #facet
  end


end
