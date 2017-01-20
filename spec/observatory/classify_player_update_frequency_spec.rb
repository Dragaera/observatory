require 'spec_helper'

module Observatory
  RSpec.describe Player do
    describe '::perform' do
      # Get rid of default frequencies
      before(:each) do
        UpdateFrequency.dataset.delete
      end

      let(:hourly) { create(:update_frequency, name: 'Hourly', interval: 60 * 60, threshold: 24 * 60 * 60) }
      let(:daily)  { create(:update_frequency, name: 'Daily', interval: 24 * 60 * 60, threshold: 7 * 24 * 60 * 60, fallback: true) }

      let(:player) { create(:player, update_frequency: daily) }

      describe 'assigns a player an update frequency depending on his activity' do
        context 'if the player has no data points yet' do
          it 'should skip classification' do
            expect(ClassifyPlayerUpdateFrequency.perform(player.id)).to be false
          end
        end

        context 'if the player has had an active update within the last hour' do
          it 'should classify it as hourly'
        end

        context 'if the player has had a relevant data point in the last week' do
          it 'should classify it as weekly'
        end

        context 'if the player has had no relevant recent update' do
          it 'should classify it with the fallback frequency'
        end
      end
    end
  end
end
