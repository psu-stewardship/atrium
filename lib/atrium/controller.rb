# Adds behaviors that Atrium needs all controllers to have. (mostly view helpers)
module Atrium::Controller
  def self.included(base)
    base.helper 'atrium/solr_helper'
  end
end
