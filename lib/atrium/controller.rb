require 'atrium/layout_helper'

# Adds behaviors that Atrium needs all controllers to have. (mostly view helpers)
module Atrium::Controller
  include Atrium::LayoutHelper

  def self.included(base)
    base.helper 'atrium/solr_helper'
  end
end
