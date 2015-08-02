'use strict';

$(function() {
  var $info = $('#info');
  var $current = $('#current');
  var $player = $('#player');
  var $playlist = $('#playlist');
  var $counter = $('#counter');

  var timer, song_len, song_current;
  var io = new RocketIO().connect();

  window.updateBar = function() {
    var percent = Math.floor(((song_len - song_current) / song_len) * 100);
    var date = new Date(null);
    var offset = 14, len = 5;

    $('#progressbar').width(percent + '%');

    date.setSeconds(song_current);
    if (song_current > 3600) {
      offset = 11;
      len = 8;
    }
    $('#timer').html(date.toISOString().substr(offset, len));

    song_current -= 1;
    timer = setTimeout(updateBar, 1000);
  };

  window.playBar = function(state, elapsed, time) {
    clearTimeout(timer);
    if (!state) {
      return;
    }
    song_current = time - elapsed;
    song_len = time;
    updateBar();
  };

  window.reloadPlayer = function() {
    $player.load();
  };

  window.toggleInfo = function() {
    $info.toggle('slow');
  }

  if ($player.length > 0) {
    $player[0].autoplay = false;
  }

  io.on('current', function(data) {
    $current.load('/ajax/current');
  });

  io.on('playlist', function(data) {
    $playlist.load('/ajax/playlist');
  });

  if ($counter.length > 0) {
    io.on('counter', function(data) {
      $counter.html(data).effect("highlight", 250);
    });
  }
});
