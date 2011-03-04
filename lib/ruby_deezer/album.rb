module RubyDeezer
  
  class Album
    
    include HTTParty
    base_uri 'api-v3.deezer.com/1.0'
    format :json
    
    attr_accessor :id, :name, :url, :image, :nb_tracks, :nb_disks, :year, :tracks, :artist
    
    def self.find(id, options = [])
      response = get("/lookup/album/", {:query => {:id => id, :output => 'json', :options => options.join(",")}})
      artist = response ? Album.init_from_hash(response['album']) : nil
    end
    
    def self.search(query, options = {})
      per_page = options.delete(:per_page) || 10
      page = options.delete(:page) || 1
      index = (page - 1) * per_page
      
      response = get("/search/album/", {:query => {:q => query, :output => 'json', :index => index, :nb_items => per_page}})
      albums = response && response["search"] && response["search"]["albums"] ? 
                  response["search"]["albums"]["album"].inject([]){|arr, hash| arr << Album.init_from_hash(hash); arr } : []
      
      
      WillPaginate::Collection.create(page, per_page) do |pager|
        pager.replace albums
        pager.total_entries = response['search']['total_results'].to_i rescue 0
      end
    end

    def self.init_from_hash(hash)
      return nil unless hash.is_a?(Hash)
      tracks = hash["tracks"] || []
      artist = hash["artist"] || {}
      Album.new.tap do |album|
        album.id = hash["id"].to_i
        album.name = hash["name"]
        album.url = hash["url"]
        album.image = hash["image"]
        album.nb_tracks = hash["nb_tracks"].to_i
        album.nb_disks = hash["nb_disks"].to_i
        album.year = hash["year"].to_i
        album.tracks = tracks.inject([]) {|arr, track| arr << Track.init_from_hash(track); arr}
        album.artist = Artist.init_from_hash(artist)
      end
    end
    
  end
  
end