require 'spec_helper'

module Observatory
  RSpec.describe SteamID do
    describe '::resolve' do
      context 'when given a custom url' do
        it 'should resolve it to an account ID' do
          expect(HiveStalker::SteamID).to receive(:from_string).and_raise(ArgumentError)
          expect(::SteamId).to receive(:resolve_vanity_url) { 54321 }
          expect(HiveStalker::SteamID).to receive(:from_string) { 12345 }

          expect(SteamID.resolve('some-test')).to eq 12345
        end
      end

      context 'when given a steam ID' do
        it 'should resolve it to an account ID' do
          expect(HiveStalker::SteamID).to receive(:from_string) { 12345 }

          expect(SteamID.resolve('U:1:12345')).to eq 12345
        end
      end

      context 'when given an invalid identifier' do
        it 'should raise an ArgumentError' do
          expect(HiveStalker::SteamID).to receive(:from_string).and_raise(ArgumentError)
          expect(::SteamId).to receive(:resolve_vanity_url) { nil }

          expect{ SteamID.resolve('this-better-not-be-a-valid-url') }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
