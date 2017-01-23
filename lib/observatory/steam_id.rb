# coding: utf-8

module Observatory
  module SteamID
    def self.resolve(identifier)
      begin
        HiveStalker::SteamID.from_string(identifier)
      rescue ArgumentError
        # Maybe a Custom URL
        HiveStalker::SteamID.from_string(resolve_custom_url(identifier))
      end
    end

    private
    def self.resolve_custom_url(identifier)
      unless Observatory::Config::Steam::WEB_API_KEY
        raise ArgumentError, "Steam API not available as no key specified!"
      end

      custom_url = identifier
      /^https?:\/\/steamcommunity\.com\/id\/([^\/]+)\/?$/.match(identifier) do |m|
        custom_url = m[1]
      end

      steam_id = SteamId.resolve_vanity_url(custom_url)
      if steam_id.nil?
        raise ArgumentError, "#{ identifier} was not a valid identifier."
      else
        steam_id
      end
    end
  end
end
