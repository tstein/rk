#!/usr/bin/perl
# vim:filetype=perl foldmethod=marker autoindent expandtab shiftwidth=4

package rk::main;

use warnings;
use strict;
use Curses;
use Switch;
use rk::UI;

$rk::main::banner = "Welcome to RK!";

my($cmdline, $cmd, $arg, $continue);



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



rk::UI::initScreen();


$continue = "true";
$cmdline = "";
while ($continue) {
    rk::UI::readstr();
}

