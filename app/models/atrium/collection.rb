class Atrium::Collection < ActiveRecord::Base
  has_many :config_items, :class_name=>'Atrium::Config::Item'
  belongs_to :config_collection_selector, :class_name=>'Atrium::Config::CollectionSelector'
  has_one :config_item_selector, :class_name=>'Atrium::Config::ItemSelector'
end
