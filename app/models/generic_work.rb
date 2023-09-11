# frozen_string_literal: true

class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include PdfBehavior
  include ::Hyrax::BasicMetadata

  if ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYKU_IIIF_PRINT', false))
    include IiifPrint.model_configuration(
      pdf_split_child_model: GenericWork,
      pdf_splitter_service: IiifPrint::TenantConfig::PdfSplitter
    )
  end

  validates :title, presence: { message: 'Your work must have a title.' }

  self.indexer = GenericWorkIndexer
end
