## About

This script will automatically control a rotor (both azimuth and elevation) based on data obtained from APRS packets (locally, or APRS-IS).

## Usage

This documentation is still a work in progress.

The gist of it is that you need to change the variables at the top of the file, setup hamlib, and run rotctld.

At K5UTD, our setup looks like this:

```rotctld -m 603 -r /dev/ttyUSB0```

You can run `rotctl -l` to list all rotors and their respective numbers.

## I really don't like writing the docs
