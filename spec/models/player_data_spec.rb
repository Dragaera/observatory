require 'spec_helper'

RSpec.describe PlayerData do
  let(:data) { create(:player_data) }

  describe '#valid?' do
    it 'should not be valid if `alias` is missing' do
      player = build(:player_data, alias: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `score` is missing' do
      player = build(:player_data, score: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `level` is missing' do
      player = build(:player_data, level: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `experience` is missing' do
      player = build(:player_data, experience: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `skill` is missing' do
      player = build(:player_data, skill: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_total` is missing' do
      player = build(:player_data, time_total: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_alien` is missing' do
      player = build(:player_data, time_alien: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_marine` is missing' do
      player = build(:player_data, time_marine: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_commander` is missing' do
      player = build(:player_data, time_commander: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `adagrad_sum` is missing' do
      player = build(:player_data, adagrad_sum: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `player_id` is missing' do
      player = build(:player_data, player_id: nil)
      expect(player).to_not be_valid
    end
  end
end
