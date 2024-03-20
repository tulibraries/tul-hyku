# frozen_string_literal: true

# OVERRIDE: Hyrax v5.0.0rc2
# - add inject_theme_views method for theming
# - add homepage presenter for access to feature flippers
# - add access to content blocks in the show method
# - adds @featured_collection_list to show method

module Hyrax
  # Shows the about and help page
  module PagesControllerDecorator
    extend ActiveSupport::Concern

    # OVERRIDE: Add for theming
    # Adds Hydra behaviors into the application controller
    include Blacklight::SearchContext
    include Blacklight::AccessControls::Catalog

    prepended do
      # OVERRIDE: Adding inject theme views method for theming
      around_action :inject_theme_views

      # OVERRIDE: Hyrax v5.0.0rc2 Add for theming
      class_attribute :presenter_class
      self.presenter_class = Hyrax::HomepagePresenter
    end

    # OVERRIDE: Add for theming
    # The search builder for finding recent documents
    # Override of Blacklight::RequestBuilders
    def search_builder_class
      Hyrax::HomepageSearchBuilder
    end

    def show
      super

      # OVERRIDE: Additional for theming
      @presenter = presenter_class.new(current_ability, collections)
      @featured_researcher = ContentBlock.for(:researcher)
      @marketing_text = ContentBlock.for(:marketing)
      @home_text = ContentBlock.for(:home_text)
      @featured_work_list = FeaturedWorkList.new
      @featured_collection_list = FeaturedCollectionList.new
      @announcement_text = ContentBlock.for(:announcement)
    end

    private

    # OVERRIDE: return collections for theming
    # Return 6 collections, sorts by title
    def collections(rows: 6)
      Hyrax::CollectionsService.new(self).search_results do |builder|
        builder.rows(rows)
        builder.merge(sort: "title_ssi")
      end
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    # OVERRIDE: Adding to prepend the theme views into the view_paths
    def inject_theme_views
      if home_page_theme && home_page_theme != 'default_home'
        original_paths = view_paths
        Hyku::Application.theme_view_path_roots.each do |root|
          home_theme_view_path = File.join(root, 'app', 'views', "themes", home_page_theme.to_s)
          prepend_view_path(home_theme_view_path)
        end
        yield
        # rubocop:disable Lint/UselessAssignment, Layout/SpaceAroundOperators, Style/RedundantParentheses
        # Do NOT change this method. This is an override of the view_paths= method and not a variable assignment.
        view_paths=(original_paths)
        # rubocop:enable Lint/UselessAssignment, Layout/SpaceAroundOperators, Style/RedundantParentheses
      else
        yield
      end
    end
  end
end

Hyrax::PagesController.prepend(Hyrax::PagesControllerDecorator)
