# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
# and copied liberally from the generic work spec
require 'rails_helper'

RSpec.describe Hyrax::ImagesController do
  let(:user) { FactoryBot.create(:user) }
  let(:work) { FactoryBot.create(:work_with_one_file, user:) }
  let(:file_set) { work.ordered_members.to_a.first }

  before do
    Hydra::Works::AddFileToFileSet.call(file_set,
                                        fixture_file_upload('images/world.png'),
                                        :original_file)
  end

  describe "#presenter" do
    subject { controller.send :presenter }

    let(:solr_document) { SolrDocument.new(FactoryBot.create(:image).to_solr) }

    before do
      allow(controller).to receive(:search_result_document).and_return(solr_document)
    end

    it "initializes a presenter" do
      expect(subject).to be_kind_of Hyku::WorkShowPresenter
      expect(subject.manifest_url).to eq "http://test.host/concern/images/#{solr_document.id}/manifest"
    end
  end

  context 'with theming' do
    it { is_expected.to use_around_action(:inject_show_theme_views) }
  end
end
