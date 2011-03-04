module RubyDeezer
  
  class Artist
    
    include HTTParty
    base_uri 'api-v3.deezer.com/1.0'
    format :json
    
    attr_accessor :id, :name, :url, :image, :similar_artists, :discography
    
    alias :albums :discography
    
    def self.find(id, options = [])
      response = get("/lookup/artist/", {:query => {:id => id, :output => 'json', :options => options.join(",")}})
      artist = response ? Artist.init_from_hash(response['artist']) : nil
    end
    
    def self.search(query, options = {})
      per_page = options.delete(:per_page) || 10
      page = options.delete(:page) || 1
      index = (page - 1) * per_page
      
      response = get("/search/artist/", {:query => {:q => query, :output => 'json', :index => index, :nb_items => per_page}})
      artists = response && response["search"] && response["search"]["artists"] ? 
                  response["search"]["artists"]["artist"].inject([]){|arr, hash| arr << Artist.init_from_hash(hash); arr } : []
      
      
      WillPaginate::Collection.create(page, per_page) do |pager|
        pager.replace artists
        pager.total_entries = response['search']['total_results'].to_i rescue 0
      end
    end

    def self.init_from_hash(hash)
      return nil unless hash.is_a?(Hash)
      similar_artists = hash["similar_artists"] || {}
      similar_artists_array = similar_artists["artist"] || []
      discography = hash["discography"] || {}
      discography_array = discography["album"] || []
      Artist.new.tap do |artist|
        artist.id = hash["id"].to_i
        artist.name = hash["name"]
        artist.url = hash["url"]
        artist.image = hash["image"]
        artist.similar_artists = similar_artists_array.inject([]) {|arr, hash| arr << init_from_hash(hash); arr}
        artist.discography = discography_array.inject([]) {|arr, hash| arr << Album.init_from_hash(hash); arr}
      end
    end
    
  end
  
  
end