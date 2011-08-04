class Atrium::Config::Field < ActiveRecord::Base
  belongs_to :config_item, :class_name=>'Atrium::Config::Item'
end
