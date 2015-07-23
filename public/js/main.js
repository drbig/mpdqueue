var $info = $('#info');
var $current = $('#current');
var $player = $('#player');
var $playlist = $('#playlist');
var $counter = $('#counter');

var timer, song_len, song_current;

function updateBar() {
  var percent = Math.floor(((song_len - song_current) / song_len) * 100);
  $('#progressbar').width(percent + '%');

  var date = new Date(null);
  date.setSeconds(song_current);
  var offset = 14, len = 5;
  if (song_current > 3600) {
    offset = 11;
    len = 8;
  }
  $('#timer').html(date.toISOString().substr(offset, len));

  song_current -= 1;
  timer = setTimeout(updateBar, 1000);
};

function playBar(state, elapsed, time) {
  clearTimeout(timer);
  if (!state) {
    return;
  }
  song_current = time - elapsed;
  song_len = time;
  updateBar();
};

function reloadPlayer() {
  $player.load();
};

function toggleInfo() {
  $info.toggle('slow');
}

if ($player.length > 0) {
  $player[0].autoplay = false;
}

var io = new RocketIO().connect();

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
