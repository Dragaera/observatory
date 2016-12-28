require 'spec_helper'

RSpec.describe Player do
  let(:player) { create(:player) }

  describe '#valid?' do
    it 'should not be valid if `account_id` is missing' do
      player = build(:player, account_id: nil)
      expect(player).to_not be_valid

      player = build(:player)
      expect(player).to be_valid
    end

    it 'should not be valid if `hive2_player_id` is missing' do
      player = build(:player, hive2_player_id: nil)
      expect(player).to_not be_valid

      player = build(:player)
      expect(player).to be_valid
    end
  end
end
