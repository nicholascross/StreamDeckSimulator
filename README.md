# Stream Deck iOS Simulator Plugin

## Features

 - Configure latitude/longitude and choose a device to set iOS simulator geolocation on key press
 - Show map on key for relevant latitude/longitude
 - Show indicator for simulator booted status on key
 
<img src="/Documentation/example2.png" width="200" height="400"/> <img src="/Documentation/example1.png" width="400" height="400"/>

 
## Installation

```
git clone https://github.com/nicholascross/StreamDeckSimulator
cd StreamDeckSimulator
open StreamDeckSimLoc.xcodeproj
```

Then build the project and a plugin package will be created in the products directory.  This can be located by right clicking on the binary and selecting "show in finder"

Alternatively you can download the latest release from here [1.2.0](https://github.com/nicholascross/StreamDeckSimulator/releases/download/1.2.0/com.nacross.stream-deck-sim-loc.streamDeckPlugin)

Double click the plugin package `com.nacross.stream-deck-sim-loc.streamDeckPlugin` to complete installation.

## How was this made?

Using this [template](https://github.com/nicholascross/template_stream_deck_swift).

## How does this work?

The simulator location is set using an undocumented API which could stop working if Apple decides to remove support for it.

Map images are captured using MapKit image snapshotter.

Simulator details are captured using `xcrun simctl` command line tool.
