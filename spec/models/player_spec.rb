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

  describe '::with_stale_data' do
    let!(:player_1) { create(:player, next_update_at: Time.now + 20 * 60 * 60) }
    let!(:player_2) { create(:player, next_update_at: Time.now + 22 * 60 * 60) }
    let!(:player_3) { create(:player, next_update_at: Time.now + 12 * 60 * 60) }
    let!(:player_4) { create(:player, next_update_at: Time.now + 36 * 60 * 60) }

    around do |example|
      Timecop.freeze(2017, 1, 1) do
        example.run
      end
    end

    it 'should return players which need an update' do
      Timecop.freeze(Time.now + 24 * 60 * 60) do
        expect(Player.with_stale_data).to match_array([player_1, player_2, player_3])
      end
    end

    it 'should not return players which already have an update scheduled' do
      player_5 = create(:player, next_update_at: Time.now + 2 * 60 * 60, update_scheduled_at: Time.now - 60 * 60)
      Timecop.freeze(Time.now + 24 * 60 * 60) do
        expect(Player.with_stale_data).to_not include(player_5)
      end
    end

    it 'should not return disabled players' do
      player_5 = create(:player, next_update_at: Time.now + 2 * 60 * 60, enabled: false)
      Timecop.freeze(Time.now + 24 * 60 * 60) do
        expect(Player.with_stale_data).to_not include(player_5)
      end
    end
  end

  describe '::by_account_id' do
    let!(:player_1) { create(:player, account_id: 1) }
    let!(:player_2) { create(:player, account_id: 2) }
    let!(:player_3) { create(:player, account_id: 3) }
    it 'should return the player with matching account id' do
      expect(Player.by_account_id(2)).to eq player_2
    end

    it 'should return nil if no player matches' do
      expect(Player.by_account_id(10)).to eq nil
    end
  end

  describe '::by_current_alias' do
    let!(:player_with_two_aliases) { create(:player, :with_player_data_points, count: 2, aliases: ['Hans', 'Mittens']) }
    let!(:john)   { create(:player, :with_player_data_points, count: 1, aliases: ['John']) }
    let!(:george) { create(:player, :with_player_data_points, count: 1, aliases: ['George']) }

    it 'should return players whose alias is an exact match' do
      result = Player.by_current_alias('John').to_a
      expect(result.count).to eq 1
      expect(result.first.id).to eq john.id
    end

    it 'should return players whose alias is a fuzzy match' do
      result = Player.by_current_alias('Johnny').to_a
      expect(result.count).to eq 1
      expect(result.first.id).to eq john.id
    end

    it 'should not return players whose previous alias is a match' do
      result = Player.by_current_alias('Hans').to_a
      expect(result).to be_empty
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

  describe '#last_activity' do
    it "should return the last time the player's data changed" do
      Timecop.freeze(Time.utc(2017, 1, 1))
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 100)
      )
      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 100)
      )
      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 150)
      )
      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 150)
      )

      expect(player.last_activity.to_time).to eq Time.utc(2017, 1, 4)
    end
  end
end
