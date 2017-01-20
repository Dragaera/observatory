require 'spec_helper'

RSpec.describe PlayerDataPoint do
  let(:data) { create(:player_data_point) }
  let(:incomplete_api_data) do
    HiveStalker::PlayerData.new(
      adagrad_sum: nil,
      alias: nil,
      experience: nil,
      player: nil,
      level: nil,
      reinforced_tier: nil,
      score: nil,
      skill: nil,
      time_total: nil,
      time_alien: nil,
      time_marine: nil,
      time_commander: nil
    )
  end

  describe '#valid?' do
    it 'should not be valid if `alias` is missing' do
      data_point = build(:player_data_point, alias: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `score` is missing' do
      data_point = build(:player_data_point, score: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `level` is missing' do
      data_point = build(:player_data_point, level: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `experience` is missing' do
      data_point = build(:player_data_point, experience: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `skill` is missing' do
      data_point = build(:player_data_point, skill: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `time_total` is missing' do
      data_point = build(:player_data_point, time_total: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `time_alien` is missing' do
      data_point = build(:player_data_point, time_alien: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `time_marine` is missing' do
      data_point = build(:player_data_point, time_marine: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `time_commander` is missing' do
      data_point = build(:player_data_point, time_commander: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `adagrad_sum` is missing' do
      data_point = build(:player_data_point, adagrad_sum: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `player_id` is missing' do
      data_point = build(:player_data_point, player_id: nil)
      expect(data_point).to_not be_valid
    end

    it 'should not be valid if `hive_player_id` is missing' do
      data_point = build(:player_data_point, hive_player_id: nil)
      expect(data_point).to_not be_valid
    end
  end

  describe '#save' do
    context 'calculates score_per_second and score_per_second_field' do
      context 'when time_total is 0' do
        it 'should set them to 0' do
          data_point = create(:player_data_point, time_total: 0)
          expect(data_point.score_per_second).to eq 0
          expect(data_point.score_per_second_field).to eq 0
        end
      end

      context 'when score is 0' do
        it 'should set them to 0' do
          data_point = create(:player_data_point, score: 0)
          expect(data_point.score_per_second).to eq 0
          expect(data_point.score_per_second_field).to eq 0
        end
      end

      context 'when neither score nor time_total is 0' do
        it 'should set score_per_second' do
          data_point = create(:player_data_point, score: 100, time_total: 20)
          expect(data_point.score_per_second).to be_within(0.01).of(5)
        end

        it 'should set score_per_second_field' do
          data_point = create(:player_data_point, score: 100, time_total: 20, time_commander: 5)
          expect(data_point.score_per_second_field).to be_within(0.01).of(100.0/15)
        end
      end
    end
  end

  describe '::build_from_player_data' do
    let(:data_point) { PlayerDataPoint.build_from_player_data_point(incomplete_api_data) }

    it 'should convert should-be float `nil` values to 0.0' do
      expect(data_point.adagrad_sum).to be_within(0.01).of(0.0)
    end

    it 'should convert should-be integer `nil` values to 0' do
      expect(data_point.experience).to eq 0
      expect(data_point.level).to eq 0
      expect(data_point.score).to eq 0
      expect(data_point.skill).to eq 0
      expect(data_point.time_total).to eq 0
      expect(data_point.time_alien).to eq 0
      expect(data_point.time_marine).to eq 0
      expect(data_point.time_commander).to eq 0
    end

    it "should convert should-be string `nil` values to ''" do
      expect(data_point.alias).to eq ''
    end

    it 'should not touch legitimiate `nil` values' do
      expect(data_point.reinforced_tier).to be_nil
    end
  end
end
