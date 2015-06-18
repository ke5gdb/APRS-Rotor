## About

This script will automatically control a rotor (both azimuth and elevation) based on data obtained from APRS packets (locally via TNC, or APRS-IS).

## Installation

1. Download the script
2. Install these dependencies:
  * hamlib2 (`sudo apt-get install libhamlib2 libhamlib-utils`)
  * Math::Round (`cpan install Math::Round`)
  * Ham::APRS::FAP (`cpan install Ham::APRS::FAP`)
  * Screen (`sudo apt-get install screen`)
3. Change the variables in the top of the script
  * APRS-IS users will need to enter their callsign and password. The password is a hash of the callsign; google it. 

## Usage

Run `rotctl -l` to list all of the available rotors. At K5UTD, we are running a Kenpro G-5400, and the homebrew interface board uses the Yaesu GS-232B protocol, so our model number is 603.

I recommend running both of these commands in screen sessions so you can disconnect and come back later, but two terminals will also get the job done.

```
rotctld -m 603 -r /dev/ttyACM0
./aprs_rotor.pl
```
