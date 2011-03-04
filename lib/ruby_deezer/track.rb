module RubyDeezer
  
  class Track
    
    include HTTParty
    base_uri 'api-v3.deezer.com/1.0'
    format :json
    
    attr_accessor :id, :name, :url, :duration, :rank, :artist, :album
    
    def self.find(id)
      response = get("/lookup/track/", {:query => {:id => id, :output => 'json'}})
      artist = response ? Track.init_from_hash(response['track']) : nil
    end
    
    def self.search(query, options = {})
      per_page = options.delete(:per_page) || 10
      page = options.delete(:page) || 1
      index = (page - 1) * per_page
      
      response = get("/search/track/", {:query => {:q => query, :output => 'json', :index => index, :nb_items => per_page}})
      tracks = response && response["search"] && response["search"]["tracks"] ? 
                  response["search"]["tracks"]["track"].inject([]){|arr, hash| arr << Track.init_from_hash(hash); arr } : []
      
      
      WillPaginate::Collection.create(page, per_page) do |pager|
        pager.replace tracks
        pager.total_entries = response['search']['total_results'].to_i rescue 0
      end
    end

    def self.init_from_hash(hash)
      return nil unless hash.is_a?(Hash)
      Track.new.tap do |track|
        track.id = hash["id"].to_i
        track.name = hash["name"]
        track.url = hash["url"]
        track.duration = hash["duration"].to_i
        track.rank = hash["rank"].to_i
        if hash["artist"]
          track.artist = Artist.init_from_hash(hash["artist"])
        end
        if hash["album"]
          track.album = Album.init_from_hash(hash["album"])
        end
      end
    end
    
  end
  
end