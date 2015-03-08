# BucknellBug

**BucknellBug** is a program for checking the current weather conditions at
Bucknell University, Lewisburg, PA, as reported by Bucknell's
[weather station][station].

## Release

Only v1.1 of BucknellBug for Mac was released. That version is not
represented in the master branch of this repository, as it was originally
tracked in a Subversion repository; the source code for the released version is
[available][source] on the BucknellBug homepage, and is marked by the `v1.1`
tag in this repository.

The version represented in this repository, slated to be v2.1, was never
released publicly, but you can build and run it yourself—the current code
works fine. However…

## Status

BucknellBug is no longer functional. According to the [weather station
website][weather], on April 8th, 2013, an electrical surge knocked out the
service, and as of October 23rd, 2014, it has yet to be restored. For now,
BucknellBug uses the [forecast.io API][sky] instead of the data supplied by
Bucknell's own weather station.

  [sky]:     https://developer.forecast.io
  [source]:  http://www.departments.bucknell.edu/geography/weather/BucknellBug-1.1.src.tgz
  [station]: http://www.departments.bucknell.edu/geography/weather/bug.html
  [weather]: http://www.departments.bucknell.edu/geography/weather/index.html

## Building

To build BucknellBug, simply open the Xcode project and select Build from the
Product menu.

You will need to create a file at Source/Application.h containing a `#define`
with your Dark Sky API key. The file should look like this:

    #define DARK_SKY_API_KEY @"<your api key>"
