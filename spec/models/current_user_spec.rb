require 'rails_helper'

RSpec.describe CurrentUser do
  let(:sunetid) { 'sunet' }
  subject(:current_user) { described_class.new(sunetid, privgroups) }

  let(:privgroups) { '' }

  describe '#sunetid' do
    context 'when it contains "@stanford.edu"' do
      let(:sunetid) { 'sunet-wo-stanford@stanford.edu' }

      it { expect(current_user.sunetid).to eq 'sunet-wo-stanford' }
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
