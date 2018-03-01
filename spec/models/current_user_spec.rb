require 'rails_helper'

RSpec.describe CurrentUser do
  subject(:current_user) { described_class.new('sunet', privgroups) }

  let(:privgroups) { '' }

  describe '#privgroups' do
    let(:privgroups) { 'priv1|priv2' }

    it 'splits a pipe delimited string into an array' do
      expect(current_user.privgroups).to eq %w[priv1 priv2]
    end
  end

  describe '#superuser?' do
    context 'when the user is in the configured privgroup' do
      let(:privgroups) { Settings.workgroups.superuser }

      it { expect(current_user).to be_superuser }
    end

    context 'when the user is not in the configured privgroup' do
      it { expect(current_user).not_to be_superuser }
    end
  end
end
