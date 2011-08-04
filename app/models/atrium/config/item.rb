class Atrium::Config::Item < ActiveRecord::Base
  belongs_to :collection, :class_name=>'Atrium::Collection'
  has_many :config_fields, :class_name=>'Atrium::Config::Field'
end
