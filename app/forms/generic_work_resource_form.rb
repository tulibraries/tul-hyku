# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericWorkResource`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class GenericWorkResourceForm < Hyrax::Forms::ResourceForm(GenericWorkResource)
  include Hyrax::FormFields(:basic_metadata)
  include Hyrax::FormFields(:generic_work_resource)
  include Hyrax::FormFields(:with_pdf_viewer)
  include Hyrax::FormFields(:with_video_embed)
  include VideoEmbedBehavior::Validation
end
