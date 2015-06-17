#!/usr/bin/perl -w

#
# APRS-Based Rotor Controller
# (C) Andrew Koenig, KE5GDB, 2015
#

use File::Tail;
use Ham::APRS::FAP qw(parseaprs direction distance);
use Math::Trig;
use Math::Round;
use IO::Socket::INET;

# Rotor configuration
my $rotorIP = "192.168.10.203";		# IP address of rotor [127.0.0.1] (rotctld)
my $rotorPort = 4533;			# Port of rotor [4533]
my $rateLimit = 30;			# Rate limit rotor updates [30]

# Groundstation Configuration
my $mylat = 32.9869;	 		# Latitude of rotor in Decimal Degrees
my $mylon = -96.7504; 			# Longitude of rotor in Decimal Degrees (west is negative!)
my $myelev = 235;			# Elevation of rotor, AMSL in meters
my $balloonPrimary = "KE5GDB-11";	# Callsign of balloon
my $balloonSecondary = "KE5GDB-3";	# Secondary balloon callsign


### End User Config ### 


# Attempt to connect to rotor
my $socket = new IO::Socket::INET (
	PeerHost => $rotorIP,
	PeerPort => $rotorPort,
	Proto => 'tcp',
);

die "Cannot connect to rotor! $!\n" unless $socket;
print "Connected to rotor!";

# Read the logfile
$file=File::Tail->new("/var/log/aprx/aprx-rf.log");
while (defined($line=$file->read)) {
	# Cut it down to just the packet
	my $packet = substr $line, 36;
	#my $packet = "KE5GDB-11>APRX28:!3321.80N/09713.40WO000/000/A=156000\n";
	my %packetdata;
	my $retval = parseaprs($packet, \%packetdata);

	if ($retval == 1) {

		if($packetdata{'type'} ne "location") {
			next;
		}

#		while (my ($key, $value) = each(%packetdata)) {
#			print "$key: $value\n";
#		}

		# Make things easier
		$call = $packetdata{'srccallsign'};
		$lat  = $packetdata{'latitude'};
		$lon  = $packetdata{'longitude'};
		$comment = $packetdata{'comment'} if exists $packetdata{'comment'};
		$comment = "<no comment>" if not exists $packetdata{'comment'};
		$alt 	 = 0 if not exists $packetdata{'altitude'};
		$alt	 = $packetdata{'altitude'} if exists $packetdata{'altitude'};
		#$symtable = $packetdata{'symboltable'};
		#$symcode  = $packetdata{'symbolcode'};
		#$time = time();

		if(($call ne $balloonPrimary) && ($call ne $balloonSecondary)) {
			next;
		}

		# Calculate bearing
		$direction = direction($mylon, $mylat, $lon, $lat);
		$distance = distance($mylon, $mylat, $lon, $lat);
		$dElev = $alt - $myelev;
		$elevation = round((180/pi)*(($dElev/($distance * 1000))-($distance/(2*6371000))));
		$distance = nearest(.1, $distance);	# This needs to be after the elevation calc to 
		$direction = round($direction); 	# maintain precision.
		$alt = round($alt);

		print "$packet";
		print "\tLat		: $lat\n";
		print "\tLon		: $lon\n";
		print "\tAlt   (m)	: $alt\n";
		print "\tDist (km)	: $distance\n";
		print "\tDir (deg)	: $direction\n";
		print "\tElev (deg)	: $elevation\n";

		# Let's be honest. I'm going to test this out by driving my truck around campus, and I don't
		# want to confuse the rotor by being beneath it. The satellite station is 70ft above all terrain
		# in a 10 mile radius. This is some hella text for one if statement. 
		if($elevation < 0) {
			$elevation = 0;
		}

		my $command = "P $direction $elevation\n";
		my $size = $socket->send($command);
		#shutdown($socket, 1);

		my $response = "";
		$socket->recv($response, 1024);
		print "\tSent data to rotor (size: $size)\n";
		print "\tReceived: $response\n\n";
	}
}

$socket->close();
