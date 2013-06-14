#!/usr/bin/perl -w
#*******************************************************************************
#* Copyright (c) 2011 IBM Corporation.
#* All rights reserved. This program and the accompanying materials
#* are made available under the terms of the Eclipse Public License v1.0
#* which accompanies this distribution, and is available at
#* http://www.eclipse.org/legal/epl-v10.html
#* 
#* Contributors:
#*     IBM Corporation - Initial Implementation
#*******************************************************************************/ 
use strict;

my $patint="([\\+\\-\\d]+)";   # Pattern for Integer number
my $patnode="([\^\\s]+(\\.[\^\\s]*)*)";       # Pattern for domain name (a.b.c)

my $portbase=50000;
my $portrange=10000;
my $verbose=0;
my $ROUTING_FILE="routing_file";
my $TOTAL_PROCS=0;
my @JOB;

my $line;
my $launchMode;
my $debuggerId;
my $pid;

#####################################################################
#
# Script to start the SDM and generate a routing table. Used when the
# ompi-ps command can't be used to obtain job information, such as
# interactive launch via job scheduler.
#
# The routing table is called 'routing_file' and it is generated in 
# the current working directory. The sdm's working directory must be
# the same location if they are to find the table. Also, any old
# routing tables should be removed before starting the sdm. 
#
# Routing table format is:
#
# num_tasks
# task_num host_name port_num
# ...
#
# where:
# 	num_tasks is the total number of tasks in the MPI job
#	task_num is the task number for a process (e.g. 0, 1, 2, etc.)
#	host_name is the hostname of the node the process is running on
#	port_num is a semi-random port number that the debugger will listen on
#
#####################################################################

sub get_node_map {
	my ($node) = @_;
    my $rank;
    my $line;
	# find proc info
	while ($line=<IN>) {
	    if ($line=~/.*Process rank: $patint/) {
	    	$rank = $1;
			$JOB[$rank] = $node;
			print "found proc $rank\n" if ($verbose);
	    } elsif ($line =~ /^$/) {
	    	print "found end of node map\n" if ($verbose);
	    	return;
	    }
	}
}

sub get_job_map {
    my $node;
    my $rank;
    my $line;
	# find node/proc info
	while ($line=<IN>) {
		if ($line=~/\s*\*+\s*/) {
			next;
		} elsif ($line=~/\s*\[$patint\] proxy: $patnode/) {
			($node,$rank) = ($2, $1);
			print "found node $node, rank $rank\n" if ($verbose);
			$TOTAL_PROCS++;
			$JOB[$rank-1] = $node;
		} elsif ($line =~ /^=+$/) {
			print "found end of table\n" if ($verbose);
			return;
		}
	}
}

sub generate_routing_file {
	open(OUT,"> $ROUTING_FILE") || die "cannot open file $ROUTING_FILE";
	printf(OUT "%d\n", $TOTAL_PROCS);
	for (my $count=0; $count < $TOTAL_PROCS; $count++) {
	    printf(OUT "%d %s %d\n",$count,$JOB[$count],$portbase+int(rand($portrange)));
	}
	close(OUT);
}

$launchMode = $ENV{'PTP_LAUNCH_MODE'};
$debuggerId = $ENV{'PTP_DEBUGGER_ID'};

if ($#ARGV < 1) {
  die " Usage: $0 [mpi_args ...] [debugger_args ...]\n";
}
my $cmd = shift(@ARGV);
my $args = join(" ", @ARGV);
if ($launchMode eq 'debug') {
	$cmd .= " -verbose";
}
print "running command $cmd $args\n" if ($verbose);

# Set autoflush to pass output as soon as possble
$|=1;

$pid = fork();
if ( $pid == 0 ) {
	printf("#PTP job_id=%d\n", $$);
	if ($launchMode eq 'debug') {
		if (open(IN,"$cmd $args 2>&1 |")) {
		    while ($line=<IN>) {
				chomp($line);
				if ($line=~/\s*Proxy information:\s*/) {
					print "found job map\n" if ($verbose);
					get_job_map();
					generate_routing_file();
				} else {
					print "$line\n";
				}
		    }
		    close(IN);
		} 
		exit(0);
	} else {
		exec($cmd, @ARGV);
		exit(1);
	}
}

waitpid($pid, 0);
exit($? >> 8);



