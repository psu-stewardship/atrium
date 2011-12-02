class::Atrium::Config::ItemSelector < ActiveRecord::Base
  belongs_to :collection, :class_name => 'Atrium::Collection'
end
