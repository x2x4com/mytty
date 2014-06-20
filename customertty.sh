#!/bin/bash
#===============================================================================
#
#         FILE:  customertty.sh
#
#        USAGE:  . customertty.sh 
#
#  DESCRIPTION:  Add Darwin support, tested on Centos/RHEL5, ubuntu 12.04LTS
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  xuxiang@zrit100.com ; x2x4com@gmail.com
#      COMPANY:  zrit
#      VERSION:  2.1 
#      CREATED:  11/12/2012 10:50:00 AM
#     REVISION:  001
#===============================================================================

#Load > $LOADHIGH not show IP
#LOADHIGH='10'

OLDLANG=$LANG
export LANG=C

IPADDRS=`perl <<'END'
use strict;
use warnings;
use Data::Dumper;


my @ifconfig_source = \`/sbin/ifconfig\`;
my $if_hash = {}; 
my $show_int = "^(en|br|tun|eth|em|bond|tap)";
my $int_name;

foreach my $line (@ifconfig_source) {
  chomp $line;
  if ($line =~ /^\s*$/) {
    $int_name = undef;
    next;
  }
  if ($line =~ /^([a-zA-Z0-9:]+)\s+/) {
    $int_name = $1; 
    $if_hash->{$int_name} = []; 
    next;
  }
  if ($line =~ /^\s+inet\s+(?:addr:)?(\d+\.\d+\.\d+\.\d+)/) {
    my $ip = $1; 
    if ($int_name) {
      my $somehash = $if_hash->{$int_name} ;
      push(@{$somehash},$ip) ;
    }   
    next;
    undef $ip;
  }
}
undef $int_name;
my $IPADDRS = " ";
foreach my $interface (sort keys %{$if_hash}) {
  if ($interface =~ /$show_int/){
    $IPADDRS .= $interface . " = ";
    my $ipaddr = $if_hash->{$interface};
    if (@{$ipaddr} == 1) {
      $IPADDRS .= $ipaddr->[0] . "; ";
    } elsif ( @{$ipaddr} == 0 ) {
      $IPADDRS .= "No IP; ";
    }
  }
}
print "$IPADDRS";
END
`
if [ "`id -u`" -eq 0 ]
then
	#PS1="---------------------------------------------------------------------------------------------\n\n[\033[34m\u\e[m@\033[32m\H\e[m] \033[1;33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#># "
	PS1="---------------------------------------------------------------------------------------------\n\n[\033[32m\u\e[m@\033[31m\H\e[m] \033[33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#># "
else
	PS1="---------------------------------------------------------------------------------------------\n\n[\033[32m\u\e[m@\033[31m\H\e[m] \033[33m$IPADDRS\e[m \n[\t] PWD => \033[1;35m\w\e[m\n\#>$ "
fi

export LANG=$OLDLANG
