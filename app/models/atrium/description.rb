class Atrium::Description < ActiveRecord::Base
  belongs_to :showcase, :class_name=>'Atrium::Showcase', :foreign_key=>"atrium_showcase_id"

  validates_presence_of  :atrium_showcase_id

  set_table_name :atrium_descriptions

  def initialize(opts={})
    super
    #facet
  end


end
