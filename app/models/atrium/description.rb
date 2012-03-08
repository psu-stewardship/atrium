require 'sanitize'
class Atrium::Description < ActiveRecord::Base
  set_table_name :atrium_descriptions

  belongs_to :showcase, :class_name => 'Atrium::Showcase', :foreign_key => 'atrium_showcase_id'
  has_one :summary, :class_name => 'Atrium::Essay',  :conditions => "\"atrium_essays\".content_type = \"summary\"", :foreign_key => 'atrium_description_id', :dependent => :destroy
  has_one :essay,   :class_name => 'Atrium::Essay',  :conditions => "\"atrium_essays\".content_type = \"essay\"", :foreign_key => 'atrium_description_id', :dependent => :destroy

  validates_presence_of :atrium_showcase_id

  accepts_nested_attributes_for :essay,   :allow_destroy => true
  accepts_nested_attributes_for :summary, :allow_destroy => true

  after_save    :update_solr unless ENV['DO_NOT_INDEX']
  after_destroy :remove_from_solr

  def pretty_title
    title.blank? ? "Description #{id}" : title
  end

  def solr_id
    "atrium_description_#{id}"
  end

  def get_atrium_showcase_id
    "atrium_showcase_#{id}"
  end

  def as_solr
    doc= {
      :id                               => solr_id,
      :format                           => "Description",
      :description_title_t              => title,
      :description_title_facet          => title,
      :description_title_display        => title,
      :summary_display                  => summary_text,
      :essay_display                    => essay_text,
      :summary_t                        => summary_text,
      :essay_t                          => essay_text,
      :atrium_showcase_id_t             => get_atrium_showcase_id,
      :atrium_showcase_id_display       => get_atrium_showcase_id
    }.reject{|key, value| value.blank?}
    puts "Doc: #{doc.inspect}"
    return doc
  end

  def summary_text
    ::Sanitize.clean(summary.content).squish unless summary.blank?
  end

  def essay_text
    ::Sanitize.clean(essay.content).squish unless essay.blank?
  end

  def to_solr
    puts "Into to Solr"
    Blacklight.solr.add as_solr
  end

  def update_solr
    to_solr
    Blacklight.solr.commit
  end

  def show_on_this_page?
    page_display.nil? || page_display == "newpage"
  end

  def blank?
    title.blank? && essay.blank?
  end

  private

  def remove_from_solr
    Blacklight.solr.delete_by_id solr_id
    Blacklight.solr.commit
  end

end
