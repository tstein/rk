#!/usr/bin/perl
# vim:filetype=perl foldmethod=marker autoindent expandtab shiftwidth=4

package rk::main;

use warnings;
use strict;
use Curses;
use Getopt::Std;
use Switch;
use rk::regex;
use rk::UI;

$rk::main::banner = "Welcome to RK!";

my(%opts, $usage, $cmdline, $cmd, $arg, $continue);


$usage = <<END
Usage: rk.pl [-t tests_file]

Options:
  -h                show this message, then exit
  -t TESTS_FILE     read tests from TESTS_FILE
END
;

# signals {{{
sub catchWINCH {
    rk::UI::resetUI();
}

sub catchINT {
    rk::UI::cleanup();
    exit(1);
}

$SIG{'INT'} = \&catchINT;
$SIG{'WINCH'} = \&catchWINCH;

# }}}



getopts('ht:', \%opts);
if ($opts{'h'}) {
    print $usage;
    exit(0);
}

if ($opts{'t'}) {
    my $tests_file = $opts{'t'};
    open(TESTS, $tests_file) or die("Could not open tests file: $!");
    while (<TESTS>) {
        my $test = $_;
        chomp($test);
        rk::regex::addTest($test);
    }
}

rk::UI::initScreen();


$continue = "true";
$cmdline = "";
while ($continue) {
    rk::UI::readstr();
}

