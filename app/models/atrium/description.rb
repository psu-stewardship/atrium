class Atrium::Description < ActiveRecord::Base
  set_table_name :atrium_descriptions

  belongs_to :showcase, :class_name => 'Atrium::Showcase', :foreign_key => 'atrium_showcase_id'
  has_one :summary, :class_name => 'Atrium::Essay',  :conditions => "\"atrium_essays\".content_type = \"summary\"", :foreign_key => 'atrium_description_id', :dependent => :destroy
  has_one :essay,   :class_name => 'Atrium::Essay',  :conditions => "\"atrium_essays\".content_type = \"essay\"", :foreign_key => 'atrium_description_id', :dependent => :destroy

  validates_presence_of :atrium_showcase_id

  accepts_nested_attributes_for :essay,   :allow_destroy => true
  accepts_nested_attributes_for :summary, :allow_destroy => true

  def pretty_title
    title.blank? ? "Description #{id}" : title
  end

  def show_on_this_page?
    page_display.nil? || page_display == "newpage"
  end

  def blank?
    title.blank? && essay.blank?
  end
end
