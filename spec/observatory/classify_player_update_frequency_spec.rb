require 'spec_helper'

module Observatory
  RSpec.describe ClassifyPlayerUpdateFrequency do
    describe '::perform' do
      let!(:hourly) { create(:update_frequency, name: 'Hourly', interval: 60 * 60, threshold: 24 * 60 * 60) }
      let!(:daily)  { create(:update_frequency, name: 'Daily', interval: 24 * 60 * 60, threshold: 7 * 24 * 60 * 60) }
      let!(:weekly)  { create(:update_frequency, name: 'Weekly', interval: 7 * 24 * 60 * 60, threshold: 52 * 24 * 60 * 60, fallback: true) }

      let!(:player) { create(:player, update_frequency_id: daily.id) }

      describe 'assigns a player an update frequency depending on his activity' do
        around :each do |example|
          UpdateFrequency.dataset.delete
          Timecop.freeze(Time.utc(2017, 1, 1, 1, 0)) do
            player.add_player_data_point(
              build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100)
            )
            player.update(last_update_at: Time.now)

            example.run
          end
        end

        context 'if the player has no data points yet' do
          it 'should skip classification' do
            expect(ClassifyPlayerUpdateFrequency.perform(create(:player, update_frequency: hourly).id)).to be false
          end
        end

        context 'if the player has had an active update within the last 24 hours' do
          before do
            Timecop.freeze(Time.now + 2 * 60 * 60)
            player.add_player_data_point(
              build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100)
            )
            player.update(last_update_at: Time.now)
          end

          it 'should classify it as hourly' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.update_frequency).to eq hourly
          end

          it 'should calculate `next_update_at`' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.next_update_at.to_time).to eq(Time.now + hourly.interval)
          end
        end

        context 'if the player has had a relevant data point in the last week' do
          before do
            Timecop.freeze(Time.now + 4 * 24 * 60 * 60)
            player.add_player_data_point(
              build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100)
            )
            player.update(last_update_at: Time.now)
          end

          it 'should classify it as daily' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.update_frequency).to eq daily
          end

          it 'should calculate `next_update_at`' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.next_update_at.to_time).to eq(Time.now + daily.interval)
          end
        end

        context 'if the player has had no relevant recent update' do
          before do
            Timecop.freeze(Time.now + 30 * 24 * 60 * 60)
            player.add_player_data_point(
              build(:player_data_point, alias: 'John', hive_player_id: 1, score: 100)
            )
            player.update(last_update_at: Time.now)
          end

          it 'should classify it with the fallback frequency' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.update_frequency).to eq weekly
          end

          it 'should calculate `next_update_at`' do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            # Yuuup.
            player.reload
            expect(player.next_update_at.to_time).to eq(Time.now + weekly.interval)
          end
        end

        it 'should schedule the next update based on the time the current update was performed' do
          player.update(next_update_at: Time.now)
          Timecop.freeze(Time.now + 2 * 60 * 60) do
            ClassifyPlayerUpdateFrequency.perform(player.id)
            player.reload

            expect(player.next_update_at.to_time).to eq (Time.now + 60 * 60)
          end
        end
      end
    end
  end
end
