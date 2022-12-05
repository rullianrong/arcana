class PlayersController < ApplicationController
    def show
        # Initiate client, player infos and game data
        client = OpenDotaApi::Client.new
        data = client.player_info(397653417)
        win_lose_data = client.win_lose_data(397653417)
        recent_matches = client.recent_matches(397653417)
        heroes_hash = client.heroes

        # Set player variables
        @account_id = data['profile']['account_id']
        @name = data['profile']['personaname']
        @avatar = data['profile']['avatarmedium']
        @steam_profile = data['profile']['profileurl']

        # Gets player rank code (integer)
        division, star = data['rank_tier'].to_s.split('')

        # Array of Dota2 divisions
        rank_tier = ['Herald', 'Guardian', 'Crusader', 'Archon', 'Legend', 'Ancient', 'Divine', 'Immortal']

        # Sets player rank
        rank_tier.each_with_index do |rank, index|
            @rank = "#{rank} #{star}" if division.to_i == index + 1
        end 

        # Show 20 recent matches
        @recent_matches_arr = Array.new

        # win counter
        recent_wins = 0 

        recent_matches.each do |match|
            hero_id = match['hero_id']
            team = match['player_slot'] <= 127 ? 'Radiant' : 'Dire'

            if (team == 'Radiant' and match['radiant_win']) or (team == 'Dire' and !match['radiant_win'])
                result = 'Won'
                recent_wins += 1
            else result = 'Lost'
            end

            # create and push new hash with game data to the array
            @recent_matches_arr << {
                team: team,
                result: result,
                gametime: seconds_to_hms(match['duration']),
                hero: heroes_hash["#{hero_id}"]['localized_name'],
                kda: "#{match['kills']}/#{match['deaths']}/#{match['assists']}"
            }
        end

         # Calculate player's 20 recent matches winrate
         winrate = ((recent_wins.to_f / 20 ) * 100).round(2)
 
         @wl = "Total Win/Lose: #{win_lose_data['win']}/#{win_lose_data['lose']}, Last 20 matches winrate = #{winrate}%"
    end

    private
    def seconds_to_hms(sec)
        [sec / 3600, sec / 60 % 60, sec % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
      end
end