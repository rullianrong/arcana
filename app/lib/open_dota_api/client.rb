class OpenDotaApi::Client
    def player_info(player_id)
        request(
            http_method: :get,
            endpoint: "players/#{player_id}"
        )
    end

    def win_lose_data(player_id)
        request(
            http_method: :get,
            endpoint: "players/#{player_id}/wl"
        )
    end

    def recent_matches(player_id)
        request(
            http_method: :get,
            endpoint: "players/#{player_id}/recentMatches"
        )
    end

    def heroes
        response = Faraday.get('https://raw.githubusercontent.com/odota/dotaconstants/master/build/heroes.json')
        JSON.parse(response.body)
    end

    private

    def client
        @_client ||= Faraday.new(ENV['BASE_URL']) do |client|
            client.request :url_encoded
            client.adapter Faraday.default_adapter
          end
    end

    def request(http_method:, endpoint:, params: {})
        response = client.public_send(http_method, endpoint, params)
        JSON.parse(response.body)
      end
end