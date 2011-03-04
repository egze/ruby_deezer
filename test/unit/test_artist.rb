require 'helper'

class TestArtist < Test::Unit::TestCase
  
  def test_should_lookup_artist
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/artist.json"))
     artist = RubyDeezer::Artist.find(1)
     
     assert_equal "Eminem", artist.name
     assert_equal 13, artist.id
     assert_equal "http://cdn-images.deezer.com/images/artist/cb286a88a55a10847d1ac0f47798380c/90x90-000000-80-0-0.jpg", artist.image
     assert_equal "http://www.deezer.com/en/music/eminem", artist.url
     assert_equal 10, artist.similar_artists.size
     assert_equal 10, artist.discography.size
     assert_equal 10, artist.albums.size
   end
   
   def test_should_search_artists
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/artists.json"))
     artists = RubyDeezer::Artist.search("emimen")

     assert_equal "50 Cent, Dr. Dre, Eminem", artists[0].name
     assert_equal "Bobby Creekwater, Eminem, Obie Trice, Nate Dogg", artists[1].name
     assert_equal 2, artists.size
     assert_equal 1, artists.current_page
     assert_equal 3, artists.total_pages
   end
  
end
