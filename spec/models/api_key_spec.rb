require 'spec_helper'

RSpec.describe APIKey do
  describe '::generate' do
    it 'generates an API key object' do
      token = SecureRandom.hex(16)
      allow(SecureRandom).to receive(:hex).and_return(token)

      api_key = APIKey.generate
      expect(api_key).to be_a APIKey
      expect(api_key.token).to eq token
    end

    it 'ensures uniqueness of generated keys' do
      tokens = [SecureRandom.hex(16), SecureRandom.hex(16)]

      allow(SecureRandom).to receive(:hex).and_return(tokens.first, tokens.first, tokens.last)

      api_key1 = APIKey.generate
      api_key1.title = 'Test'
      api_key1.save

      api_key2 = APIKey.generate

      expect(api_key2.token).to eq tokens.last
    end
  end

  describe '::authenticate' do
    let(:token1)   { SecureRandom.hex(16) }
    let(:token2)   { SecureRandom.hex(16) }

    it 'returns nil if token does not match' do
      create(:api_key, token: token1)
      expect(APIKey.authenticate(token2)).to be_nil
    end

    it 'returns nil if the key is inactive' do
      create(:api_key, :inactive, token: token1)
      expect(APIKey.authenticate(token1)).to be_nil
    end

    it 'returns the key if all matches' do
      api_key = create(:api_key, token: token1)
      expect(APIKey.authenticate(token1)).to eq api_key
    end
  end
end
