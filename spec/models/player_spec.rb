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

  describe '::by_steam_id' do
    let!(:player) { create(:player, account_id: 48221310) }
    it 'should return nil if no player matches' do
      expect(Player.by_steam_id('STEAM_0:0:24110000')).to be_nil
    end
    it 'should return the player if Steam ID matches' do
      expect(Player.by_steam_id('STEAM_0:0:24110655')).to eq player
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
      player.update(last_update_at: Time.now)

      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 100)
      )
      player.update(last_update_at: Time.now)

      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 150)
      )
      player.update(last_update_at: Time.now)

      Timecop.freeze(Time.now + 24 * 60 * 60)
      player.add_player_data_point(
        build(:player_data_point, alias: 'John', score: 150)
      )
      player.update(last_update_at: Time.now)

      expect(player.last_activity.to_time).to eq Time.utc(2017, 1, 4)
    end
  end

  describe '#update_data' do
    context 'when querying for data succeeds' do
      let(:stalker_success) do
        stalker = double(HiveStalker::Stalker)
        allow(stalker).to receive(:get_player_data) do
          HiveStalker::PlayerData.new(
            adagrad_sum: 0.1,
            alias: 'John',
            experience: 10,
            player_id: 1,
            level: 5,
            reinforced_tier: nil,
            score: 50,
            skill: 200,
            time_total: 10,
            time_alien: 3,
            time_marine: 7,
            time_commander: 2,
            badges: ['commander', 'dev'],
          )
        end
        stalker
      end

      it 'should unset `update_scheduled_at`' do
        player.update(update_scheduled_at: Time.now)
        expect { player.update_data(stalker: stalker_success) }.to(
          change { player.update_scheduled_at }.to(nil)
        )
      end

      it 'should reset error-handling fields' do
        player.update(error_count: 2, error_message: 'Foo')
        expect { player.update_data(stalker: stalker_success) }.to(
          change { player.error_count }.to(0).and(
            change { player.error_message }.to(nil)
          )
        )
      end

      it 'should re-enable the player' do
        player.update(enabled: false)
        expect { player.update_data(stalker: stalker_success) }.to(
          change { player.enabled }.to(true)
        )
      end

      it 'should add a new data point with supplied data' do
        expect { player.update_data(stalker: stalker_success) }.to(
          change { player.player_data_points_dataset.count }.to(1)
        )

        # Good enough of a check. Probably. ;)
        expect(player.alias).to eq 'John'
      end

      it 'should add badges based on supplied data' do
        badge_commander = Badge.where(key: 'commander').first
        badge_dev       = Badge.where(key: 'dev').first

        player.update_data(stalker: stalker_success)

        expect(player.badges.to_a).to include badge_commander
        expect(player.badges.to_a).to include badge_dev
      end

      it 'should not re-add existing badges' do
        player.update_data(stalker: stalker_success)

        expect { player.update_data(stalker: stalker_success) }.to_not change { player.badges_dataset.count }
      end
    end

    context 'when querying for data fails' do
      let(:stalker_failure) do
        stalker = double(HiveStalker::Stalker)
        allow(stalker).to receive(:get_player_data).and_raise(HiveStalker::APIError, 'API error')
        stalker
      end

      it 'should increase error count' do
        expect { player.update_data(stalker: stalker_failure) }.to(
          change{ player.error_count }.from(0).to(1).
          and raise_error HiveStalker::APIError
        )
      end

      it 'should store the error message' do
        expect { player.update_data(stalker: stalker_failure) }.to(
          change{ player.error_message }.to('API error').
          and raise_error HiveStalker::APIError
        )
      end

      context 'and the player has no data points' do
        it 'should disable the player if requisites are met' do
          player.update(error_count: Observatory::Config::Player::ERROR_THRESHOLD - 1)
          expect { player.update_data(stalker: stalker_failure) }.to(
            change{ player.enabled }.to(false).
            and raise_error HiveStalker::APIError
          )
        end
      end

      context 'and the player has data points' do
        it 'should not disable the player' do
          player = create(:player, :with_player_data_points, count: 1, aliases: %w(John))
          player.update(error_count: Observatory::Config::Player::ERROR_THRESHOLD - 1)
          expect { player.update_data(stalker: stalker_failure) }.to raise_error HiveStalker::APIError
          expect(player.enabled).to be true
        end
      end

      it 'should unset `update_scheduled_at`' do
        player.update(update_scheduled_at: Time.now)
        expect { player.update_data(stalker: stalker_failure) }.to(
          change{ player.update_scheduled_at }.to(nil).
          and raise_error HiveStalker::APIError
        )
      end
    end
  end

  describe '#rank' do
    let!(:player_1) { create(:player, next_update_at: Time.now + 20 * 60 * 60) }
    let!(:player_2) { create(:player, next_update_at: Time.now + 22 * 60 * 60) }
    let!(:player_3) { create(:player, next_update_at: Time.now + 12 * 60 * 60) }

    before do
      player_1.add_player_data_point(build(:player_data_point, skill: 100))
      player_2.add_player_data_point(build(:player_data_point, skill: 10))
      player_3.add_player_data_point(build(:player_data_point, skill: 11))
    end

    context 'when querying for a single column' do
      it 'should return the rank of the player for the queried columns' do
        expect(player_1.rank(:skill)[:rank_skill]).to eq 1
        expect(player_2.rank(:skill)[:rank_skill]).to eq 3
        expect(player_3.rank(:skill)[:rank_skill]).to eq 2
      end
    end
  end

  describe '#show_ensl_tutorials?' do
    it 'should return true if skill is below, and playtime above, a given threshold' do
      player = create(:player)
      player.add_player_data_point(create(:player_data_point, player_id: player.id, skill: 1_000, time_total: 60 * 60 * 12))

      expect(player.show_ensl_tutorials?).to be_truthy
    end

    it 'should return false if skill is above a given threshold' do
      player = create(:player)
      player.add_player_data_point(create(:player_data_point, player_id: player.id, skill: 3_000, time_total: 60 * 60 * 12))

      expect(player.show_ensl_tutorials?).to be_falsy
    end

    it 'should return false if playtime is below a given threshold' do
      player = create(:player)
      player.add_player_data_point(create(:player_data_point, player_id: player.id, skill: 1_000, time_total: 60 * 60 * 4))

      expect(player.show_ensl_tutorials?).to be_falsy
    end

    it 'should return false if showing of tutorials is disabled' do
      stub_const('Observatory::Config::Profile::ENSL::SHOW_TUTORIALS', false)
      player = create(:player)
      player.add_player_data_point(create(:player_data_point, player_id: player.id, skill: 1_000, time_total: 60 * 60 * 12))

      expect(player.show_ensl_tutorials?).to be_falsey
    end

    it 'should return false if the player has no data points' do
      player = create(:player, :with_player_data_points, count: 0)

      expect(player.show_ensl_tutorials?).to be_falsey
    end
  end

  describe '#rookie?' do
    it "returns true if the player's level is below 20" do
      player.add_player_data_point(build(:player_data_point, player: player, level: 10))
      expect(player).to be_rookie
    end

    it 'returns true if the player has no data points' do
      expect(player).to be_rookie
    end

    it 'returns false otherwise' do
      player.add_player_data_point(build(:player_data_point, player: player, level: 21))
      expect(player).to_not be_rookie
    end
  end

  describe '#skill_tier_badge' do
    it 'returns the rookie badge if player is a rookie' do
      player.add_player_data_point(build(:player_data_point, player: player, level: 10))

      expect(player.skill_tier_badge).to eq SkillTierBadge.rookie
    end

    it "returns the highest badge the player's skill permits otherwise" do
      player.add_player_data_point(build(:player_data_point, player: player, level: 50, skill: 2202, adagrad_sum: 1000))

      expect(player.skill_tier_badge).to eq SkillTierBadge.commandant
    end
  end
end
