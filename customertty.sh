#!/usr/bin/env bash
#===============================================================================
#
#         FILE:  customertty.sh
#
#        USAGE:  . customertty.sh
#
#  DESCRIPTION:  Add Darwin support, tested on Centos/RHEL5/6, ubuntu 12.04LTS
#
#       UPDATE:  20140621 增加了类似eth0:0 这样的方式显示
#                20150620 增加了自适应的横线，仅限于第一次适应
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  xuxiang@zrit100.com ; x2x4com@gmail.com
#      COMPANY:  ZRIT
#      VERSION:  2.3
#      CREATED:  11/12/2012 10:50:00 AM
#     REVISION:  001
#===============================================================================

#Load > $LOADHIGH not show IP
#LOADHIGH='10'

OLDLANG=$LANG
export LANG=C
COLUMNS=$(tput cols)

if [[ -n $COLUMNS ]]; then
  width=$(perl -e "print '-' x $COLUMNS")
else
  width="---------------------------------------------------------------------------------------------"
fi


function print_ip_addr () {
    perl << 'END'
    use strict;
    use warnings;
    use Data::Dumper;


    my @ifconfig_source = `/sbin/ifconfig`;
    my $if_hash = {};
    my $show_int = "^(en|wl|ww|br|tun|eth|em)";
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
}


PS1='${width}\n\n[\033[32m\u\e[m@\033[31m\H\e[m] \033[33m$(print_ip_addr)\e[m \n[\D{%Y-%m-%d %H:%M:%S}] PWD => \033[1;35m\w\e[m\n\#>\$ '
export LANG=$OLDLANG
