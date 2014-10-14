#!/usr/bin/perl -w
# $Id: check_mem.pl 2 2002-02-28 06:42:51Z egalstad $

# Original script stolen from:
# check_mem.pl Copyright (C) 2000 Dan Larsson <dl@tyfon.net>
# hacked by
# Justin Ellison <justin@techadvise.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);  if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA

# Tell Perl what we need to use
use strict;
use Getopt::Std;

#TODO - Convert to Nagios::Plugin
#TODO - Use an alarm

# Predefined exit codes for Nagios
use vars qw($opt_c $opt_f $opt_u $opt_w $opt_C $opt_v %exit_codes);
%exit_codes   = ('UNKNOWN' ,-1,
        		 'OK'      , 0,
                 'WARNING' , 1,
                 'CRITICAL', 2,
                 );

# Get our variables, do our checking:
init();

# Get the numbers:
my ($free_memory_mb,$used_memory_mb,$caches_mb) = get_memory_info();
print "$free_memory_mb Free\n$used_memory_mb Used\n$caches_mb Cache\n" if ($opt_v);

if ($opt_C) { #Do we count caches as free?
    $used_memory_mb -= $caches_mb;
    $free_memory_mb += $caches_mb;
}

# Round to the nearest KB
$free_memory_mb = sprintf('%d',$free_memory_mb);
$used_memory_mb = sprintf('%d',$used_memory_mb);
$caches_mb = sprintf('%d',$caches_mb);

# Tell Nagios what we came up with
tell_nagios($used_memory_mb,$free_memory_mb,$caches_mb);


sub tell_nagios {
    my ($used,$free,$caches) = @_;
    
    # Calculate Total Memory
    my $total = $free + $used;
    print "$total Total\n" if ($opt_v);

    my $total_b=$total*1024*1024;
    my $used_b=$used*1024*1024;
    my $free_b=$free*1024*1024;
    my $caches_b=$caches*1024*1024;


    my $perfdata = "|TOTAL=${total_b}B;;;; USED=${used_b}B;;;; FREE=${free_b}B;;;; CACHES=${caches_b}B;;;;";
    
    if ($opt_f) {
      my $percent    = sprintf "%.1f", ($free / $total * 100);
      if ($percent <= $opt_c) {
          finish("CRITICAL - $percent% ($free MB) free!$perfdata",$exit_codes{'CRITICAL'});
      }
      elsif ($percent <= $opt_w) {
          finish("WARNING - $percent% ($free MB) free!$perfdata",$exit_codes{'WARNING'});
      }
      else {
          finish("OK - $percent% ($free MB) free.$perfdata",$exit_codes{'OK'});
      }
    }
    elsif ($opt_u) {
      my $percent    = sprintf "%.1f", ($used / $total * 100);
      if ($percent >= $opt_c) {
          finish("CRITICAL - $percent% ($used MB) used!$perfdata",$exit_codes{'CRITICAL'});
      }
      elsif ($percent >= $opt_w) {
          finish("WARNING - $percent% ($used MB) used!$perfdata",$exit_codes{'WARNING'});
      }
      else {
          finish("OK - $percent% ($used MB) used.$perfdata",$exit_codes{'OK'});
      }
    }
}

# Show usage
sub usage() {
  print "\ncheck_mem.pl v1.0 - Nagios Plugin\n\n";
  print "usage:\n";
  print " check_mem.pl -<f|u> -w <warnlevel> -c <critlevel>\n\n";
  print "options:\n";
  print " -f           Check FREE memory\n";
  print " -u           Check USED memory\n";
  print " -C           Count OS caches as FREE memory\n";
  print " -w PERCENT   Percent free/used when to warn\n";
  print " -c PERCENT   Percent free/used when critical\n";
  print "\nCopyright (C) 2000 Dan Larsson <dl\@tyfon.net>\n";
  print "check_mem.pl comes with absolutely NO WARRANTY either implied or explicit\n";
  print "This program is licensed under the terms of the\n";
  print "GNU General Public License (check source code for details)\n";
  exit $exit_codes{'UNKNOWN'}; 
}

sub get_memory_info {
    my $used_memory_mb  = 0;
    my $free_memory_mb  = 0;
    my $total_memory_mb = 0;
    my $caches_mb       = 0;

    my $uname;
    if ( -e '/usr/bin/uname') {
        $uname = `/usr/bin/uname -a`;
    }
    elsif ( -e '/bin/uname') {
        $uname = `/bin/uname -a`;
    }
    else {
        die "Unable to find uname in /usr/bin or /bin!\n";
    }
    print "uname returns $uname" if ($opt_v);
    if ( $uname =~ /Linux/ ) {
        my @meminfo = `/bin/cat /proc/meminfo`;
        foreach (@meminfo) {
            chomp;
            if (/^Mem(Total|Free):\s+(\d+) kB/) {
                my $counter_name = $1;
                if ($counter_name eq 'Free') {
                    $free_memory_mb = $2/1024;
                }
                elsif ($counter_name eq 'Total') {
                    $total_memory_mb = $2/1024;
                }
            }
            elsif (/^(Buffers|Cached):\s+(\d+) kB/) {
                $caches_mb += $2/1024;
            }
        }
        $used_memory_mb = $total_memory_mb - $free_memory_mb;
    }
    elsif ( $uname =~ /SunOS/ ) {
        eval "use Sun::Solaris::Kstat";
        if ($@) { #Kstat not available
            if ($opt_C) {
                print "You can't report on Solaris caches without Sun::Solaris::Kstat available!\n";
                exit $exit_codes{UNKNOWN};
            }
            my @vmstat = `/usr/bin/vmstat 1 2`;
            my $line;
            foreach (@vmstat) {
              chomp;
              $line = $_;
            }
            $free_memory_mb = (split(/ /,$line))[5] / 1024;
            my @prtconf = `/usr/sbin/prtconf`;
            foreach (@prtconf) {
                if (/^Memory size: (\d+) Megabytes/) {
                    $total_memory_mb = $1 * 1024;
                }
            }
            $used_memory_mb = $total_memory_mb - $free_memory_mb;
            
        }
        else { # We have kstat
            my $kstat = Sun::Solaris::Kstat->new();
            my $phys_pages = ${kstat}->{unix}->{0}->{system_pages}->{physmem};
            my $free_pages = ${kstat}->{unix}->{0}->{system_pages}->{freemem};
            # We probably should account for UFS caching here, but it's unclear
            # to me how to determine UFS's cache size.  There's inode_cache,
            # and maybe the physmem variable in the system_pages module??
            # In the real world, it looks to be so small as not to really matter,
            # so we don't grab it.  If someone can give me code that does this, 
            # I'd be glad to put it in.
            my $arc_size = (exists ${kstat}->{zfs} && ${kstat}->{zfs}->{0}->{arcstats}->{size}) ?
                 ${kstat}->{zfs}->{0}->{arcstats}->{size} / 1024 
                 : 0;
            $caches_mb += $arc_size;
            my $pagesize = `pagesize`;
    
            $total_memory_mb = $phys_pages * $pagesize / 1024;
            $free_memory_mb = $free_pages * $pagesize / 1024;
            $used_memory_mb = $total_memory_mb - $free_memory_mb;
        }
    }
    elsif ( $uname =~ /AIX/ ) {
        my @meminfo = `/usr/bin/vmstat -v`;
        foreach (@meminfo) {
            chomp;
            if (/^\s*([0-9.]+)\s+(.*)/) {
                my $counter_name = $2;
                if ($counter_name eq 'memory pages') {
                    $total_memory_mb = $1*4;
                }
                if ($counter_name eq 'free pages') {
                    $free_memory_mb = $1*4;
                }
                if ($counter_name eq 'file pages') {
                    $caches_mb = $1*4;
                }
            }
        }
        $used_memory_mb = $total_memory_mb - $free_memory_mb;
    }
    else {
        if ($opt_C) {
            print "You can't report on $uname caches!\n";
            exit $exit_codes{UNKNOWN};
        }
    	my $command_line = `vmstat | tail -1 | awk '{print \$4,\$5}'`;
    	chomp $command_line;
        my @memlist      = split(/ /, $command_line);
    
        # Define the calculating scalars
        $used_memory_mb  = $memlist[0]/1024;
        $free_memory_mb = $memlist[1]/1024;
        $total_memory_mb = $used_memory_mb + $free_memory_mb;
    }
    return ($free_memory_mb,$used_memory_mb,$caches_mb);
}

sub init {
    # Get the options
    if ($#ARGV le 0) {
      &usage;
    }
    else {
      getopts('c:fuCvw:');
    }
    
    # Shortcircuit the switches
    if (!$opt_w or $opt_w == 0 or !$opt_c or $opt_c == 0) {
      print "*** You must define WARN and CRITICAL levels!\n";
      &usage;
    }
    elsif (!$opt_f and !$opt_u) {
      print "*** You must select to monitor either USED or FREE memory!\n";
      &usage;
    }
    
    # Check if levels are sane
    if ($opt_w <= $opt_c and $opt_f) {
      print "*** WARN level must not be less than CRITICAL when checking FREE memory!\n";
      &usage;
    }
    elsif ($opt_w >= $opt_c and $opt_u) {
      print "*** WARN level must not be greater than CRITICAL when checking USED memory!\n";
      &usage;
    }
}

sub finish {
    my ($msg,$state) = @_;
    print "$msg\n";
    exit $state;
}
