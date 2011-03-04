require 'helper'

class TestAlbum < Test::Unit::TestCase
  
  def test_should_lookup_album
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/album.json"))
     album = RubyDeezer::Album.find(1)
     
     assert_equal "Vapeurs Toxiques", album.name
     assert_equal 1, album.nb_disks
     assert_equal 0, album.nb_tracks
     assert_equal 64, album.id
     assert_equal "http://www.deezer.com/en/music/don-choa/vapeurs-toxiques-64", album.url
     assert_equal "http://cdn-images.deezer.com/images/cover/162922e3732a312053f14bb47480ce84/150x150-000000-80-0-0.jpg", album.image
     assert album.tracks.empty?
   end
   
   def test_should_search_albums
     FakeWeb.register_uri(:get, %r|http://api-v3.deezer.com/1.0|, :body => File.read(File.dirname(__FILE__) + "/../fixtures/albums.json"))
     albums = RubyDeezer::Album.search("emimen")

     assert_equal 2, albums.size
     assert_equal 1, albums.current_page
     assert_equal 10, albums.total_pages
     assert_equal "Recovery", albums[0].name
     assert_equal "Relapse", albums[1].name    
   end
  
end
