# -*- encoding : utf-8 -*-
module Atrium
  class Routes

    def initialize(router, options)
      @router = router
      @options = options
    end

    def draw
      route_sets.each do |r|
        self.send(r)
      end
    end

    protected

    def add_routes &blk
      @router.instance_exec(@options, &blk)
    end

    def route_sets
      (@options[:only] || default_route_sets) - (@options[:except] || [])
    end

    def default_route_sets
      [:atrium_collections, :catalog, :get]
    end

    module RouteSets

      def atrium_collections
        add_routes do |options|
          resources :atrium_collections, :atrium_exhibits do
            resource :atrium_showcases
          end
          resources :atrium_descriptions
          match 'atrium_collections/:id/exhibit_order',        :to => 'atrium_collection_exhibit_order#index',       :as => 'atrium_collection_exhibit_order'
          match 'atrium_collections/:id/exhibit_order/update', :to => 'atrium_collection_exhibit_order#update',      :as => 'update_atrium_collection_exhibit_order', :via => :post
          match 'atrium_collections/:collection_id/catalog', :to => 'catalog#index'
          match 'atrium_collections/configure/:id',         :to => 'atrium_collections#home_page_text_config', :as => 'atrium_collection_text_configure'
          match 'atrium_exhibits/:id/facet_order',          :to => 'atrium_exhibit_facet_order#index',         :as => 'atrium_exhibit_facet_order'
          match 'atrium_exhibits/:id/facet_order/update',   :to => 'atrium_exhibit_facet_order#update',        :as => 'update_atrium_exhibit_facet_order', :via => :post
          match 'atrium_showcases/featured/:id',          :to => 'atrium_showcases#featured',              :as => 'atrium_showcase_featured'
          match 'atrium_showcases/configure/:id',         :to => 'atrium_showcases#configure_showcase', :as => 'atrium_showcase_configure'
          match 'atrium_collections/:collection_id/catalog/:id', :to => 'catalog#show', :as => 'atrium_collection_catalog'
          match 'atrium_collections/:collection_id/browse/:id', :to => 'catalog#show', :as => 'atrium_collection_browse', :defaults=>{:atrium_collection_browse=>true}
          match 'atrium_collections/:collection_id/exhibits/:exhibit_id/browse/:id', :to => 'catalog#show', :as => 'atrium_collection_exhibit_browse', :defaults=>{:atrium_exhibit_browse=>true}
          match 'atrium_exhibits/:exhibit_id/browse/:id', :to => 'catalog#show', :as => 'atrium_exhibit_browse', :defaults=>{:atrium_exhibit_browse=>true}
        end
      end

      def catalog
        add_routes do |options|
          match 'catalog/:id/edit', :to => 'catalog#edit', :as => 'edit_catalog'
          # The delete method renders a confirmation page with a button to submit actual destroy request
          match 'catalog/:id/delete', :to => 'catalog#delete', :as => 'delete_catalog'
	  ### The rest of these routes are defined in blacklight
          #resources :catalog, :id=> /.+/
         # resources :catalog, :only => [:index, :show], :controller => "hydra_head/catalog", :path_prefix => HydraHead::Engine.config.mount_at, :as => "hydra_head", :id=> /.+/
          #match 'catalog/:id', :to => "hydra_head/catalog#show", :path_prefix => HydraHead::Engine.config.mount_at, :as => "catalog", :id => /.+/
          #match 'catalog/:id', :to => "hydra_head/catalog#show", :id => /.+/
          # match 'about', :to => 'catalog#about', :as => 'about'
        end
      end


      def get
        add_routes do |options|
          resources :get, :only=>:show
        end
      end


    end
    include RouteSets

#match 'generic_contents_object/content/:container_id', :to => 'generic_content_objects#create', :as => 'generic_content_object', :via => :post
  end
end
