require 'spec_helper'

RSpec.describe Player do
  let!(:player1) { create(:player, account_id: 1) }
  let!(:player2) { create(:player, account_id: 2) }
  let(:player_data_existing) do
    HiveStalker::PlayerData.new(
      adagrad_sum: 0.1,
      alias: 'Testuser',
      badges: ['commander'],
      badges_enabled: true,
      experience: 100,
      level: 10,
      player_id: 102,
      reinforced_tier: nil,
      score: 150,
      skill: 100,
      steam_id: 2,
      time_alien: 100,
      time_commander: 20,
      time_marine: 100,
      time_total: 200
    )
  end
  let(:player_data_new) do
    HiveStalker::PlayerData.new(
      adagrad_sum: 0.1,
      alias: 'Testuser',
      badges: ['commander'],
      badges_enabled: true,
      experience: 100,
      level: 10,
      player_id: 102,
      reinforced_tier: nil,
      score: 150,
      skill: 100,
      steam_id: 101,
      time_alien: 100,
      time_commander: 20,
      time_marine: 100,
      time_total: 200
    )
  end

  describe '::from_player_data' do
    it 'should return the matching player if he exists' do
      expect(Player.from_player_data(player_data_existing).id).to eq player2.id
    end

    context 'when the player does not exist' do
      it 'should create a new player' do
        player = Player.from_player_data(player_data_new)
        expect(player.hive2_player_id).to eq 102
        expect(player.account_id).to eq 101
        expect(player.reinforced_tier).to eq nil
      end

      it 'should create a data point for that player' do
        player = Player.from_player_data(player_data_new)
        expect(player.current_player_data).to_not be_nil

        expect(player.adagrad_sum).to be_within(0.001).of(0.1)
        expect(player.alias).to eq 'Testuser'
        expect(player.experience).to eq 100
        expect(player.level).to eq 10
        expect(player.score).to eq 150
        expect(player.skill).to eq 100
        expect(player.time_total).to eq 200
        expect(player.time_alien).to eq 100
        expect(player.time_marine).to eq 100
        expect(player.time_commander).to eq 20
      end
    end
  end

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
