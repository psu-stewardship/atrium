class Atrium::Config::CollectionSelector < ActiveRecord::Base
  has_many :collections, :class_name => 'Atrium::Collection'
end
