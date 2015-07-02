# MPDQueue

Super-simple live-updating "player frontend" webapp for MPD.

![MPDQueue in action](http://i.imgur.com/XL3D5nz.png)

Features:

 - Currently playing with progress bar and a timer
 - Indicator for normal and random playback
 - Playlist
 - Auto-updating on change
 - HTML5 widget for in-browser playback
 - Additional info box
 - Easily configurable
 - Looks good

## Setup

```bash
$ git clone https://github.com/drbig/mpdqueue.git
$ cd mpdqueue
$ cp default.yaml my.yaml
$ $EDITOR my.yaml
$ bundle
$ ./mpdqueue.rb my.yaml
```

Dependencies:
 - Modern Ruby
 - Four GEMs

Configuration options:

```yaml
---
:host: 127.0.0.1
:port: 8989
:io_port: 8988
:title: My mpd queue
:mpd_host: 127.0.0.1
:mpd_port: 6600
# options below are not mandatory, you can delete them
:contact: mailto:your@mail.address
:stream_playlist: http://link.to/playlist.m3u
:stream_direct: http://direct.stream/url
:stream_widget: false # you need to set stream_direct above for this to work
:info_title: Help
:info_text: Some text # you need to set info_title above too for this to work
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
