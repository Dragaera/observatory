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
  end

  describe '#add_player_data_point' do
    let(:data_point1) { build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100) }
    let(:data_point2) { build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100) }
    let(:data_point3) { build(:player_data_point, alias: 'John', hive_player_id: 1, score: 150) }

    it 'should set `current_player_data_point` to the new data point' do
      player.add_player_data_point(data_point1)
      expect(player.current_player_data_point).to eq data_point1

      player.add_player_data_point(data_point2)
      expect(player.current_player_data_point).to eq data_point2
    end

    context 'determines and sets `relevant` on the new data point' do
      context 'if it is equal to the current one' do
        it 'should set it to false' do
          player.add_player_data_point(data_point1)
          player.add_player_data_point(data_point2)

          expect(data_point1).to be_relevant
          expect(data_point2).to_not be_relevant
        end
      end

      context 'if it differs from the current one' do
        it 'should set it to true' do
          player.add_player_data_point(data_point1)
          player.add_player_data_point(data_point3)

          expect(data_point1).to be_relevant
          expect(data_point3).to be_relevant
        end
      end
    end
  end
end
