# MPDQueue

~~Super-simple~~ Cool live-updating "player frontend" webapp for MPD.

Features:

 - Currently playing with progress bar and a timer
 - Indicator for normal and random playback
 - Current playlist
 - Auto-updating on change
 - HTML5 widget for in-browser playback
 - Additional info box
 - Support for multiple streams and/or playlist URLs
 - Online users counter
 - Can search for and show album art
 - Album art, if found, can be made into a "buy now" link
 - Also makes sense when JavaScript is disabled in browser
 - Easily configurable
 - Looks good

*Note*: Might not actually be cool. Screenshot presents minimal features.

![MPDQueue in action](http://i.imgur.com/XL3D5nz.png)

## Setup

```bash
$ git clone https://github.com/drbig/mpdqueue.git
$ cd mpdqueue
$ cp default.yaml my.yaml
$ $EDITOR my.yaml
$ bundle install
$ ./mpdqueue.rb my.yaml
```

Dependencies:
 - Modern Ruby
 - Five GEMs

Configuration options:

```yaml
---
:host: 127.0.0.1
:port: 8989
:io_port: 8988
:title: My mpd queue
:mpd_host: 127.0.0.1
:mpd_port: 6600
:version: false # set to string to display, with false it'll try use git --describe
# options below are not mandatory, you can delete them
:contact: mailto:your@mail.address
:stream_playlist: http://link.to/playlist.m3u # can be an array
:stream_direct: http://direct.stream/url # can be an array
# for the following to work you need at least one stream_direct URL defined,
# in case of an array it will use only the first entry
:stream_widget: false
:stream_format: audio/ogg
:info_title: Help
:info_text: Some text # you need to set info_title above too for this to work
:counter: false # show online users counter
:album_art: false # try to fetch and show album art from iTunes
 # generate a 'buy now' link, by substituting "artist album", so an example
 # shop_link value: http://www.amazon.com/s/field-keywords=%s
 # works only if album_art is enabled and album art has been found
:shop_link: false
```

## Contributing

Follow the usual GitHub workflow:

 1. Fork the repository
 2. Make a new branch for your changes
 3. Work (and remember to commit with decent messages)
 4. Push your feature branch to your origin
 5. Make a Pull Request on GitHub

## Licensing

Standard two-clause BSD license, see LICENSE.txt for details.

Copyright (c) 2015 Piotr S. Staszewski
