require 'spec_helper'

RSpec.describe PlayerDataPoint do
  let(:data) { create(:player_data_point) }

  describe '#valid?' do
    it 'should not be valid if `alias` is missing' do
      player = build(:player_data_point, alias: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `score` is missing' do
      player = build(:player_data_point, score: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `level` is missing' do
      player = build(:player_data_point, level: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `experience` is missing' do
      player = build(:player_data_point, experience: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `skill` is missing' do
      player = build(:player_data_point, skill: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_total` is missing' do
      player = build(:player_data_point, time_total: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_alien` is missing' do
      player = build(:player_data_point, time_alien: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_marine` is missing' do
      player = build(:player_data_point, time_marine: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `time_commander` is missing' do
      player = build(:player_data_point, time_commander: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `adagrad_sum` is missing' do
      player = build(:player_data_point, adagrad_sum: nil)
      expect(player).to_not be_valid
    end

    it 'should not be valid if `player_id` is missing' do
      player = build(:player_data_point, player_id: nil)
      expect(player).to_not be_valid
    end
  end
end
