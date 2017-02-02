require 'spec_helper'

RSpec.describe PlayerQuery do
  let(:query) { create(:player_query) }

  let(:resolver_success) do
    resolver = double(Observatory::SteamID)
    allow(resolver).to receive(:resolve) { 12345 }

    resolver
  end
  let(:resolver_failure) do
    resolver = double(Observatory::SteamID)
    allow(resolver).to receive(:resolve).and_raise(ArgumentError, 'Invalid identifier')

    resolver
  end

  let(:stalker_success) do
    stalker = double(HiveStalker::Stalker)
    allow(stalker).to receive(:get_player_data) do
      HiveStalker::PlayerData.new(
        adagrad_sum: 0.1,
        alias: 'Foo',
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
        badges: [],
      )
    end

    stalker
  end
  let(:stalker_failure) do
    stalker = double(HiveStalker::Stalker)
    allow(stalker).to receive(:get_player_data).and_raise(HiveStalker::APIError, 'API error')

    stalker
  end

  describe '#valid?' do
    it 'should not be valid if `query` is missing' do
      query = build(:player_query, query: nil)
      expect(query).to_not be_valid

      query = build(:player_query)
      expect(query).to be_valid
    end
  end

  describe '#save' do
    it 'should set the default value of `pending` to true' do
      expect(query).to be_pending
    end
  end

  describe '#execute' do
    it 'should set `pending` to false' do
      query.execute(resolver: resolver_success)

      expect(query).to_not be_pending
    end

    it 'should set the `executed_at` timestamp' do
      query.execute(resolver: resolver_success)

      expect(query.executed_at).to_not be_nil
    end

    context 'when querying for data succeeds' do
      it 'should set `success` to true' do
        query.execute(resolver: resolver_success)

        expect(query.success).to be true
      end

      it 'should set `account_id`' do
        query.execute(resolver: resolver_success)

        expect(query.account_id).to eq 12345
      end

      it "should return the updated player" do
        result = query.execute(resolver: resolver_success)

        expect(result).to be_a Player
      end
    end

    context 'when querying for data fails' do
      context 'due to an invalid identifier' do
        it 'should set `success` to false' do
          query.execute(resolver: resolver_failure)

          expect(query.success).to be false
        end

        it 'should set `error_message`' do
          query.execute(resolver: resolver_failure)

          expect(query.error_message).to eq 'Invalid identifier'
        end
      end
    end
  end
end
