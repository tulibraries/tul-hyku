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

      private

        Request = Struct.new(:base_url, keyword_init: true)

        def request
          Request.new(base_url: hostname)
        end

        def image_content
          return nil unless latest_file_id
          url = Hyrax.config.iiif_image_url_builder.call(
            latest_file_id,
            request.base_url,
            Hyrax.config.iiif_image_size_default,
            solr_document.mime_type
          )

          # Serving up only prezi 3
          image_content_v3(url)
        end

        def video_display_content(_url, label = '')
          width = solr_document.width&.try(:to_i) || 320
          height = solr_document.height&.try(:to_i) || 240
          duration = conformed_duration_in_seconds
          IIIFManifest::V3::DisplayContent.new(
            # Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(
            #   solr_document.id,
            #   label: label,
            #   host: request.base_url
            # ),
            # TODO: This is a hack to pull the download url from hyrax as the video resource.
            #       Ultimately we want to fix the processing times of the video derivatives so it doesn't take
            #       hours to days to complete.  The draw back of doing it this way is that we're using the original
            #       video file which is fine if it's already processed, but if it's a raw, then it is not ideal for
            #       streaming purposes.  The good thing is that PALs seem to be processing the video derivatives out
            #       of band first before ingesting so we shouldn't run into this issue.
            Hyrax::Engine.routes.url_helpers.download_url(solr_document.id, host: request.base_url, protocol: 'https'),
            label: label,
            width: width,
            height: height,
            duration: duration,
            type: 'Video',
            format: solr_document.mime_type
          )
        end

        def audio_content
          streams = stream_urls
          if streams.present?
            streams.collect { |label, url| audio_display_content(url, label) }
          else
            # OVERRIDE, because we're hard coding `audio/mpeg`, it doesn't make sense to support `ogg`
            # See: https://github.com/samvera-labs/hyrax-iiif_av/blob/6273f90016c153d2add33f85cc24285d51a25382/app/presenters/concerns/hyrax/iiif_av/displays_content.rb#L118
            audio_display_content(download_path('mp3'), 'mp3')
          end
        end

        def audio_display_content(_url, label = '')
          duration = conformed_duration_in_seconds
          IIIFManifest::V3::DisplayContent.new(
            Hyrax::IiifAv::Engine.routes.url_helpers.iiif_av_content_url(
              solr_document.id,
              label: label,
              host: request.base_url
            ),
            label: label,
            duration: duration,
            type: 'Sound',
            # instead of relying on the mime type of the original file, we hard code it to `audio/mpeg`
            # because this is pointing to the mp3 derivative, also UV doesn't support specifically `audio/x-wave`
            format: 'audio/mpeg'
          )
        end

        def conformed_duration_in_seconds
          if Array(solr_document.duration)&.first&.count(':') == 3
            # takes care of milliseconds like ["0:0:01:001"]
            Time.zone.parse(Array(solr_document.duration).first.sub(/.*\K:/, '.')).seconds_since_midnight
          elsif Array(solr_document.duration)&.first&.include?(':')
            # if solr_document.duration evaluates to something like ["0:01:00"] which will get converted to seconds
            Time.zone.parse(Array(solr_document.duration).first).seconds_since_midnight
          else
            # handles cases if solr_document.duration evaluates to something like ['25 s']
            Array(solr_document.duration).first.try(:to_f)
          end ||
            400.0
        end
    end
  end
end

Hyrax::IiifAv::DisplaysContent.prepend(Hyrax::IiifAv::DisplaysContentDecorator)
