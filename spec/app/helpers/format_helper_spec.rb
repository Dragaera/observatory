require 'spec_helper'

RSpec.describe "Observatory::App::FormatHelperHelper" do
  let(:helpers){ Class.new }
  before { helpers.extend Observatory::App::FormatHelperHelper }
  subject { helpers }

  describe '.pp_timespan' do
    it 'should handle sub-minute timespans' do
      expect(subject.pp_timespan(45)).to eq '45s'
    end

    it 'should handle timespans equal to one minute' do
      expect(subject.pp_timespan(60)).to eq '1m'
    end

    it 'should handle timespans above one minute' do
      expect(subject.pp_timespan(145)).to eq '2m 25s'
    end

    it 'should handle timespans equal to one hour' do
      expect(subject.pp_timespan(2 * 60 * 60)).to eq '2h'
    end

    it 'should handle timespans above one hour' do
      expect(subject.pp_timespan(4 * 60 * 60 + 4 * 60 + 4)).to eq '4h 4m 4s'
    end

    it 'should handle timespans above or equal to one day' do
      expect(subject.pp_timespan(3 * 24 * 60 * 60 + 2 * 60 * 60 + 20)).to eq '3d 2h 20s'
    end
  end

  describe 'pp_separator' do
    it 'should handle numbers with less than four digits' do
      expect(subject.pp_separator(123)).to eq '123'
    end

    it 'should handle numbers with four digits' do
      expect(subject.pp_separator(1234)).to eq "1'234"
    end

    it 'should handle numbers which split into pairs of three digits' do
      expect(subject.pp_separator(123456)).to eq "123'456"
      expect(subject.pp_separator(426347234)).to eq "426'347'234"
    end

    it 'should handle numbers with surplus digits' do
      expect(subject.pp_separator(1234567)).to eq "1'234'567"
      expect(subject.pp_separator(29257128453)).to eq "29'257'128'453"
    end

    it 'should handle a custom separator' do
      expect(subject.pp_separator(123456, '.')).to eq '123.456'
    end
  end

  describe '.pp_percentage' do
    it 'should return a well-formatted percentage' do
      expect(subject.pp_percentage(23, 100)).to eq '23.0%'
      expect(subject.pp_percentage(3, 9)).to eq '33.3%'
    end

    it 'should support varying accuriacies' do
      expect(subject.pp_percentage(3, 9, 3)).to eq '33.333%'
    end
  end
end
