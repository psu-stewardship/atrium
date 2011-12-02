class Atrium::Config::Item < ActiveRecord::Base
  has_many :config_fields, :class_name => 'Atrium::Config::Field'
  belongs_to :collection,  :class_name => 'Atrium::Collection'
end
