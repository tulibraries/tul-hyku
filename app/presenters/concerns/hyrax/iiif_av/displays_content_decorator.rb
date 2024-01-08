# frozen_string_literal: true

module Hyrax
  module IiifAv
    # main reasons for this decorator is to override variable names from hyrax-iiif_av
    #   solr_document => object
    #   current_ability => @ability
    #   request.base_url => hostname
    # also to remove #auth_service since it was not working for now
    module DisplaysContentDecorator
      def solr_document
        defined?(super) ? super : object
      end

      def current_ability
        defined?(super) ? super : @ability
      end


      Request = Struct.new(:base_url, keyword_init: true)

      def request
        Request.new(base_url: hostname)
      end
    end
  end
end

Hyrax::IiifAv::DisplaysContent.prepend(Hyrax::IiifAv::DisplaysContentDecorator)
