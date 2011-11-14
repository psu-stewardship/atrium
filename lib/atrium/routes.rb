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
      [:atrium_exhibits, :catalog, :get]
    end

    module RouteSets

      def atrium_exhibits
        add_routes do |options|
          resources :atrium_exhibits, :atrium_showcases do
            resource :atrium_browse_pages
          end
          resources :atrium_descriptions
          match 'atrium_exhibits/:id/showcase_order',        :to => 'atrium_exhibit_showcase_order#index',       :as => 'atrium_exhibit_showcase_order'
          match 'atrium_exhibits/:id/showcase_order/update', :to => 'atrium_exhibit_showcase_order#update',      :as => 'update_atrium_exhibit_showcase_order', :via => :post
          match 'atrium_showcases/:id/facet_order',          :to => 'atrium_showcase_facet_order#index',         :as => 'atrium_showcase_facet_order'
          match 'atrium_showcases/:id/facet_order/update',   :to => 'atrium_showcase_facet_order#update',        :as => 'update_atrium_showcase_facet_order', :via => :post
          match 'atrium_browse_pages/featured/:id',          :to => 'atrium_browse_pages#featured',              :as => 'atrium_browse_page_featured'
          match 'atrium_browse_pages/configure/:id',         :to => 'atrium_browse_pages#configure_browse_page', :as => 'atrium_browse_page_configure'
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
