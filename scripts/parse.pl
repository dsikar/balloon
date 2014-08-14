#!/usr/bin/perl -w

use lib '/home6/mailinfo/scripts/balloon/lib';
use Balloon;

use strict;

#################################
#				#
#   Balloon PZ altitude check	#
#				#    
#   Daniel Sikar dsikar@gmail	#
#				#
#################################

# new object
my $balloon = Balloon->new();

$balloon->path('/home6/mailinfo/scripts/balloon/');

# load config file
$balloon->config();

# get command line argument
my $file = $ARGV[0];

# get pilot number from file name
$balloon->file($file);

open(FILE, "< $file" ) or die "Can't open $file : $!";
while(<FILE>)
{       
	my @list = split(',', $_);
	if($#list == $balloon->arraysize()) {
		
		# store logger easting
		$balloon->l_easting($list[$balloon->ei()]);
		
		# store logger northing
		$balloon->l_northing($list[$balloon->ni()]);
		
		# store logger altitude
		$balloon->altitude($list[$balloon->ai()]); 

		# find crossing, as set in config file
		$balloon->find();
	}
}

# print one line report
$balloon->report();
 
