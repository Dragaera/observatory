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
    allow(stalker).to receive(:get_player_data) { HiveStalker::PlayerData.new(alias: 'Foobar') }

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
      query.execute(resolver: resolver_success, stalker: stalker_success)

      expect(query).to_not be_pending
    end

    it 'should set the `executed_at` timestamp' do
      query.execute(resolver: resolver_success, stalker: stalker_success)

      expect(query.executed_at).to_not be_nil
    end

    context 'when querying for data succeeds' do
      it 'should set `success` to true' do
        query.execute(resolver: resolver_success, stalker: stalker_success)

        expect(query.success).to be true
      end

      it 'should set `account_id`' do
        query.execute(resolver: resolver_success, stalker: stalker_success)

        expect(query.account_id).to eq 12345
      end

      it "should return the player's data" do
        result = query.execute(resolver: resolver_success, stalker: stalker_success)

        expect(result.alias).to eq 'Foobar'
      end
    end

    context 'when querying for data fails' do
      context 'due to an API failure' do
        it 'should set `success` to false' do
          query.execute(resolver: resolver_success, stalker: stalker_failure)

          expect(query.success).to be false
        end

        it 'should set `error_message`' do
          query.execute(resolver: resolver_success, stalker: stalker_failure)

          expect(query.error_message).to eq 'API error'
        end
      end

      context 'due to an invalid identifier' do
        it 'should set `success` to false' do
          query.execute(resolver: resolver_failure, stalker: stalker_failure)

          expect(query.success).to be false
        end

        it 'should set `error_message`' do
          query.execute(resolver: resolver_failure, stalker: stalker_failure)

          expect(query.error_message).to eq 'Invalid identifier'
        end
      end
    end
  end
end
