## About

This script will automatically control a rotor (both azimuth and elevation) based on data obtained from APRS packets (locally via TNC, or APRS-IS).

## Installation

1. Download the script
2. Install these dependencies:
..* hamlib2 (`sudo apt-get install libhamlib2 libhamlib-utils`)
..* Math::Round (`cpan install Math::Round`)
..* Ham::APRS::FAP (`cpan install Ham::APRS::FAP`)
3. Change the variables in the top of the script
..* APRS-IS users will need to enter their callsign and password. The password is a hash of the callsign; google it. 

## Usage

At K5UTD, our setup looks like this:

```rotctld -m 603 -r /dev/ttyUSB0```

You can run `rotctl -l` to list all rotors and their respective numbers.

## I really don't like writing the docs
