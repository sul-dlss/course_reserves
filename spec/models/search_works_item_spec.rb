# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchWorksItem do
  subject(:item) { described_class.new('6490288') }
  let(:document) { {} }
  let(:json) { { 'response' => { 'document' => document} } }

  before do
    expect(Faraday).to(
      receive(:get).with('https://searchworks.stanford.edu/view/6490288.json')
    ).and_return(double('FaradayResponse', body: json.to_json))
  end

  describe '#valid?' do
    context 'without a title' do
      it { expect(item).not_to be_valid }
    end

    context 'with a title' do
      let(:document) { { 'title_full_display' => 'Cats!' } }

      it { expect(item).to be_valid }
    end
  end

  describe '#to_h' do
    let(:document) do
      {
        'title_full_display' => 'Cats!',
        'imprint_display' => ['1st ed. - Mordor']
      }
    end

    it { expect(item.to_h).to include(ckey: '6490288') }
    it { expect(item.to_h).to include(title: 'Cats!') }
    it { expect(item.to_h).to include(imprint: '1st ed. - Mordor') }
    it { expect(item.to_h).to include(online: false) }

    context 'when an item available via Hathi ETAS' do
      let(:document) { { 'ht_access_sim' => ['AnyValue'] } }

      it { expect(item.to_h).to include(online: true) }
    end

    context 'when an item available via online (according the SW access facet)' do
      let(:document) { { 'access_facet' => ['At the Library', 'Online'] } }

      it { expect(item.to_h).to include(online: true) }
    end

    context 'when a media item' do
      let(:document) { { 'title_full_display' => 'Cats!', format_main_ssim: ['Book', 'Video'] } }

      it { expect(item.to_h).to include(media: true) }
      it { expect(item.to_h).to include(loan_period: '4 hours') }
    end
  end
end
