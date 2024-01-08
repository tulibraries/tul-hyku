# frozen_string_literal: true

RSpec.describe ApplicationHelper do
  describe "#markdown" do
    let(:header) { '# header' }
    let(:bold) { '*bold*' }

    it 'renders markdown into html' do
      expect(helper.markdown(header)).to eq("<h1>header</h1>\n")
      expect(helper.markdown(bold)).to eq("<p><em>bold</em></p>\n")
    end
  end
end
