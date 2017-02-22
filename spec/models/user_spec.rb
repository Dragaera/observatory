require 'spec_helper'

RSpec.describe User do
  # Can't use lazy-loading, as user needs to be present for auth tests.
  let!(:user_john) { create(:user, :active, user: 'john', password: 'you shall not pass') }
  let!(:user_george) { create(:user, :inactive, user: 'george', password: 'go home please') }

  describe '#valid?' do
    it 'should validate presence of #user' do
      user = build(:user, user: nil)
      expect(user).to_not be_valid

      user.user = 'user'
      expect(user).to be_valid
    end

    it 'should validate uniqueness of #user' do
      user = build(:user, user: 'john')
      expect(user).to_not be_valid

      user.user = 'john2'
      expect(user).to be_valid
    end

    it 'should validate presence of #password' do
      user = build(:user, password: nil)
      expect(user).to_not be_valid

      user.password = 'password'
      expect(user).to be_valid
    end
  end

  describe '#password' do
    it 'should return a BCrypt object' do
      expect(user_john.password).to be_a BCrypt::Password
    end

    it 'shoud compare equal to the plaintext password' do
      expect(user_john.password).to eq 'you shall not pass'
    end

    it 'should not compare equal to other passwords' do
      expect(user_john.password).to_not eq 'let us be friends'
    end
  end

  describe '#password=' do
    it 'should hash the password' do
      expect(user_john.password.to_s).to_not eq 'you shall not pass'
    end
  end

  describe '::authenticate' do
    it 'should return nil if no user exists' do
      expect(User.authenticate('no_such_user', 'test')).to be_nil
    end

    it 'should return nil if the password does not match' do
      expect(User.authenticate('john', 'this is not the password you want')).to be_nil
    end

    it 'should return nil if the user is inactive' do
      expect(User.authenticate('george', 'go home please')).to be_nil
    end

    it 'should return the user if he exists, the password matches, and he is active' do
      expect(User.authenticate('john', 'you shall not pass')).to eq user_john
    end
  end
end
