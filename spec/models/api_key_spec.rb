require 'spec_helper'

RSpec.describe APIKey do
  describe '::generate' do
    it 'generates an API key object' do
      token = SecureRandom.uuid
      key   = SecureRandom.hex(16)
      allow(SecureRandom).to receive(:uuid).and_return(token)
      allow(SecureRandom).to receive(:hex).and_return(key)

      api_key = APIKey.generate
      expect(api_key).to be_a APIKey
      expect(api_key.token).to eq token
      expect(api_key.key).to eq key
    end

    it 'ensures uniqueness of generated keys' do
      tokens = [SecureRandom.uuid, SecureRandom.uuid]
      keys   = [SecureRandom.hex(16), SecureRandom.hex(16)]

      allow(SecureRandom).to receive(:uuid).and_return(tokens.first, tokens.first, tokens.last)
      allow(SecureRandom).to receive(:hex).and_return(keys.first, keys.first, keys.last)

      api_key1 = APIKey.generate
      api_key2 = APIKey.generate

      expect(api_key2.token).to eq tokens.last
      expect(api_key2.key).to eq keys.last
    end
  end

  describe '::authenticate' do
    let(:token1) { SecureRandom.uuid }
    let(:token2) { SecureRandom.uuid }
    let(:key1)   { SecureRandom.hex(16) }
    let(:key2)   { SecureRandom.hex(16) }

    it 'returns nil if token does not match' do
      create(:api_key, token: token1, key: key1)
      expect(APIKey.authenticate(token2, key1)).to be_nil
    end

    it 'returns nil if key does not match' do
      create(:api_key, token: token1, key: key1)
      expect(APIKey.authenticate(token1, key2)).to be_nil
    end

    it 'returns nil if the key is inactive' do
      create(:api_key, :inactive, token: token1, key: key1)
      expect(APIKey.authenticate(token1, key1)).to be_nil
    end

    it 'returns the key if all matches' do
      api_key = create(:api_key, token: token1, key: key1)
      expect(APIKey.authenticate(token1, key1)).to eq api_key
    end
  end
end
