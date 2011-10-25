class AtriumBrowsePagesController < ApplicationController

  include Blacklight::SolrHelper
  include Atrium::ExhibitsHelper
  include Atrium::SolrHelper
  include CatalogHelper
  include BlacklightHelper

  layout 'atrium'

  before_filter :initialize_exhibit, :except=>[:index, :new, :create]

  def edit

  end

  def update

  end

  def destroy

  end
end
