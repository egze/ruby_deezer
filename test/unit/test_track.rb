require 'helper'

class TestTrack < Test::Unit::TestCase
  
  def test_should_lookup_track
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/track.json"))
     track = RubyDeezer::Track.find(1)
     
     assert_equal "Don't Lie", track.name
     assert_equal 13, track.id
     assert_equal 219, track.duration
     assert_equal 0, track.rank
     assert_equal 'http://www.deezer.com/listen-13', track.url
     assert_equal "Black Eyed Peas", track.artist.name
     assert_equal "Monkey Business", track.album.name
   end
   
   def test_should_search_tracks
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/tracks.json"))
     tracks = RubyDeezer::Track.search("emimen")
     
     assert_equal 3, tracks.size
     assert_equal 1, tracks.current_page
     assert_equal 50, tracks.total_pages
     assert_equal "Superman", tracks[0].name
     assert_equal "Crack A Bottle", tracks[1].name
     assert_equal "Cold Wind Blows", tracks[2].name
     assert_equal "Eminem", tracks[0].artist.name
     assert_equal "Dr. Dre, 50 Cent, Eminem", tracks[1].artist.name
     assert_equal "Eminem", tracks[2].artist.name
     assert_equal "The Eminem Show", tracks[0].album.name
     assert_equal "Crack A Bottle", tracks[1].album.name
     assert_equal "Recovery", tracks[2].album.name
   end
  
end
