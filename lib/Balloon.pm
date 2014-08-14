#!/usr/bin/perl -w

package Balloon;
use strict;

# TODO
# 1. Vertical and Horizontal cases in sub find{}

##################################################
## the object constructor (simplistic version)  ##
##################################################

sub new {
    my $self  = {};	
	
	# file path	
    $self->{PATH} = undef;

	# config file parsed parameters 
    $self->{ARRAYSIZE} = undef;
    $self->{EASTING} = undef;
    $self->{NORTHING} = undef;
    $self->{EASTING1} = undef;
    $self->{NORTHING1} = undef;
    $self->{MIN_ALT} = undef;
    $self->{EI} = undef;
    $self->{NI} = undef;
    $self->{AI} = undef;

	# logger easting northing pairs to define a straight line
    $self->{L_EASTING} = undef;
    $self->{L_NORTHING} = undef;
    $self->{ALTITUDE} = undef;

	# line equation calculation and storing parameters
    $self->{SLOPE} = undef;
    $self->{M} = undef;
    $self->{B} = undef;
    $self->{MIN_NORTHING_DIFF} = undef;
    $self->{LOGGER_EASTING} = undef;
    $self->{LOGGER_NORTHING} = undef;
    $self->{CROSSING_ALTITUDE} = undef;
    $self->{MIN_PROXIMITY} = undef;

	# pilot details extracted from file name
    $self->{FILE} = undef;
    $self->{PILOT_NUMBER} = undef;
    $self->{FLIGHT_CODE} = undef;
	
    bless($self);           
    return $self;
}

##############################################
## methods to access per-object data        ##
##                                          ##
## With args, they set the value.  Without  ##
## any, they only retrieve it/them.         ##
##############################################

sub path {
    my $self = shift;
    if (@_) { $self->{PATH} = shift }
    return $self->{PATH};
}

sub arraysize {
    my $self = shift;
    if (@_) { $self->{ARRAYSIZE} = shift }
    return $self->{ARRAYSIZE};
}

sub ei {
    my $self = shift;
    if (@_) { $self->{EI} = shift }
    return $self->{EI};
}

sub ni {
    my $self = shift;
    if (@_) { $self->{NI} = shift }
    return $self->{NI};
}

sub ai {
    my $self = shift;
    if (@_) { $self->{AI} = shift }
    return $self->{AI};
}

sub easting {
    my $self = shift;
    if (@_) { $self->{EASTING} = shift }
    return $self->{EASTING};
}

sub northing {
    my $self = shift;
    if (@_) { $self->{NORTHING} = shift }
    return $self->{NORTHING};
}

sub easting1 {
    my $self = shift;
    if (@_) { $self->{EASTING1} = shift }
    return $self->{EASTING1};
}

sub northing1 {
    my $self = shift;
    if (@_) { $self->{NORTHING1} = shift }
    return $self->{NORTHING1};
}

sub slope {
    my $self = shift;
    if (@_) { $self->{SLOPE} = shift }
    return $self->{SLOPE};
}

sub l_easting {
    my $self = shift;
    if (@_) { $self->{L_EASTING} = shift }
    return $self->{L_EASTING};
}

sub l_northing {
    my $self = shift;
    if (@_) { $self->{L_NORTHING} = shift }
    return $self->{L_NORTHING};
}

sub altitude {
    my $self = shift;
    if (@_) { $self->{ALTITUDE} = shift }
    return $self->{ALTITUDE};
}

sub min_logger_distance {
    my $self = shift;
    if (@_) { $self->{MIN_NORTHING_DIFF} = shift }
    return $self->{MIN_NORTHING_DIFF};
}

sub logger_easting {
    my $self = shift;
    if (@_) { $self->{LOGGER_EASTING} = shift }
    return $self->{LOGGER_EASTING};
}

sub logger_northing {
    my $self = shift;
    if (@_) { $self->{LOGGER_NORTHING} = shift }
    return $self->{LOGGER_NORTHING};
}

sub crossing_altitude {
    my $self = shift;
    if (@_) { $self->{CROSSING_ALTITUDE} = shift }
    return $self->{CROSSING_ALTITUDE};
}

# methods

sub config {
    my $self = shift;
    my $configfilepath = $self->{PATH} . 'config/config';
    
    # open file
	open(FILE, "< $configfilepath" ) or die "Can't open configuration $configfilepath : $!";
		while(<FILE>)
		{       
		chomp;
		my @list = split('=', $_);
		if($#list == 1) {
			# cases
			if($list[0] eq 'ARRAYSIZE') {
				$self->{ARRAYSIZE} = $list[1];
			}

			if($list[0] eq 'EASTING') {
				$self->{EASTING} = $list[1];
			}

			if($list[0] eq 'NORTHING') {
				$self->{NORTHING} = $list[1];
			}

			if($list[0] eq 'EASTING1') {
				$self->{EASTING1} = $list[1];
			}

			if($list[0] eq 'NORTHING1') {
				$self->{NORTHING1} = $list[1];
			}

			if($list[0] eq 'MIN_ALT') {
				$self->{MIN_ALT} = $list[1];
			}

			if($list[0] eq 'MIN_PROXIMITY') {
				$self->{MIN_PROXIMITY} = $list[1];
			}

			if($list[0] eq 'EI') {
				$self->{EI} = $list[1];
			}

			if($list[0] eq 'NI') {
				$self->{NI} = $list[1];
			}

			if($list[0] eq 'AI') {
				$self->{AI} = $list[1];
			}
		}
	}

	$self->set_slope();
}

sub file {
	my $self = shift;
	$self->{FILE} = shift;
	my $file = $self->{FILE};
	$file = substr($file, 14, 12);
	$self->{FLIGHT_CODE} = substr($file, 0, 5);
	$self->{PILOT_NUMBER} = substr($file, 5, 3);
}

# determine slope

sub set_slope {
	my $self = shift;

	# postive slope
	if(($self->{EASTING} < $self->{EASTING1}) && ($self->{NORTHING} < $self->{NORTHING1})) {
		$self->{SLOPE} = "P";
	}

	# negative slope
	if(($self->{EASTING} < $self->{EASTING1}) && ($self->{NORTHING} > $self->{NORTHING1})) {
		$self->{SLOPE} = "N";
	}

	# vertical line
	if($self->{EASTING} == $self->{EASTING1}) {
		$self->{SLOPE} = "V";
	}

	# horizontal line
	if($self->{NORTHING} == $self->{NORTHING1}) {
		$self->{SLOPE} = "H";
	}

	# variables for line equation y = mx + b
	$self->{M} = ($self->{NORTHING} - $self->{NORTHING1}) / ($self->{EASTING} - $self->{EASTING1});
	$self->{B} = $self->{NORTHING1} - ($self->{M} * $self->{EASTING1});

}

# determine proximity of point to line

sub find {
	my $self = shift;

	# case 1, positive slope ~ X =< X2 =< X1 ,  Y =< Y2 =< Y1, logger easting and northing within line segment
	if($self->{SLOPE} eq "P" && 
		$self->{EASTING} <= $self->{L_EASTING} && $self->{L_EASTING} <= $self->{EASTING1} &&
		$self->{NORTHING} <= $self->{L_EASTING} && $self->{L_NORTHING} <= $self->{NORTHING1}) {
		# find the y value on the slope for the logger easting
		$self->set_y_proximity();
	}

	# case 2, negative slope ~ X =< X2 =< X1 , Y => Y2 => Y1, logger easting and northing within line segment
	if($self->{SLOPE} eq "N" && 
		$self->{EASTING} <= $self->{L_EASTING} && $self->{L_EASTING} <= $self->{EASTING1} && 
		$self->{NORTHING} >= $self->{L_EASTING} && $self->{L_NORTHING} >= $self->{NORTHING1}) {

		# find the y value on the slope for the logger easting
		$self->set_y_proximity();			
	}

	# case 3, vertical line ~  Y =< Y2 =< Y1, logger northing within line segment NB X,Y must be lowest of line segment coordinate pairs i.e. Y < Y1
	# don't worry about this one for now

	# case 4, horizontal line ~  X =< X2 =< X1, logger easting within line segment NB X,Y must be leftmost of line segment coordinate pairs i.e. X < Y1
	# don't worry about this one for now
	
}

sub set_y_proximity {
	my $self = shift;
	# line equation y = mx + b, the mx + b part being $self->{M} * $self->{L_EASTING} + $self->{B}, sets
	# y on the slope for a given logger easting (x), this y is subtracted from the logger y i.e. $self->{L_NORTHING}
	# to set distance between both ys (motorway y and logger y)

	my $y_proximity =  $self->{L_NORTHING} - ($self->{M} * $self->{L_EASTING} + $self->{B});
	# set absolute value
	if($y_proximity < 0) {
		$y_proximity = $y_proximity * -1;
	}

	# ignored points too far (as defined in config file) from motorway
	if($y_proximity > $self->{MIN_PROXIMITY}) {
		return;
	}

	# init
	if(! defined $self->{MIN_NORTHING_DIFF}) {
		$self->{MIN_NORTHING_DIFF} = $y_proximity;
	} 

	# store
	if($y_proximity <= $self->{MIN_NORTHING_DIFF}) {
		# log
		$self->{MIN_NORTHING_DIFF} = $y_proximity;
		$self->{LOGGER_EASTING} = $self->{L_EASTING};
		$self->{LOGGER_NORTHING} = $self->{L_NORTHING};
 		$self->{CROSSING_ALTITUDE} = $self->{ALTITUDE};
	}
}

sub report {
	my $self = shift;

	# Flight code printed once from main.sh
	#print $self->{FLIGHT_CODE};
	#print "\t";
	
	print $self->{PILOT_NUMBER};
	print "\t";
	if(! defined $self->{MIN_NORTHING_DIFF}) {
		print "NO CROSSING FOUND\n";	
		return;
	}

	# minimum distance found, only for debugging
	print $self->{MIN_NORTHING_DIFF};
	print "\t";

	#print "\nLogger Easting = ";
	print $self->{LOGGER_EASTING};
	#print "\nLogger Northing = ";
	print "\t";
	print $self->{LOGGER_NORTHING};
	#print "\nCrossing Altitude = ";
	print "\t";
	print $self->{CROSSING_ALTITUDE};
	print "(m)";
	print "\t";
	
	my $crossing_altitude_in_feet = $self->{CROSSING_ALTITUDE} * 3.28;
	print "$crossing_altitude_in_feet(ft) ";
	print ($crossing_altitude_in_feet < $self->{MIN_ALT} ? "*" : "");
	print "\n";

	
}

1;  # required for .pm modules