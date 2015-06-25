$(function() {
  var $current = $('#current');
  var $playlist = $('#playlist');

  $current.load('/ajax/current');
  $playlist.load('/ajax/playlist');

  var io = new RocketIO().connect();

  io.on('state', function(data) {
    $current.load('/ajax/current');
  });

  io.on('current', function(data) {
    $current.load('/ajax/current');
  });

  io.on('playlist', function(data) {
    $playlist.load('/ajax/playlist');
  });
});
