# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GenericWork do
  describe 'class configuration' do
    subject { described_class }

    its(:migrating_from) { is_expected.to eq(GenericWork) }
    its(:migrating_to) { is_expected.to eq(GenericWorkResource) }

    context '.model_name' do
      subject { described_class.model_name }

      its(:klass) { is_expected.to eq GenericWork }
      its(:name) { is_expected.to eq "GenericWork" }

      its(:singular) { is_expected.to eq "generic_work" }
      its(:plural) { is_expected.to eq "generic_works" }
      its(:element) { is_expected.to eq "generic_work" }
      its(:human) { is_expected.to eq "Generic work" }
      its(:collection) { is_expected.to eq "generic_works" }
      its(:param_key) { is_expected.to eq "generic_work" }
      its(:i18n_key) { is_expected.to eq :generic_work }
      its(:route_key) { is_expected.to eq "hyrax_generic_works" }
      its(:singular_route_key) { is_expected.to eq "hyrax_generic_work" }
    end
  end
end
