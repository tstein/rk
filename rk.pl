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
sub cleanup {
    endwin();
}

sub catchWINCH {
    cleanup();
}

sub catchINT {
    cleanup();
    exit(1);
}

$SIG{'INT'} = \&catchINT;
$SIG{'WINCH'} = \&catchINT;

# }}}



rk::UI::initScreen();


$continue = "true";
$cmdline = "";
while ($continue) {
    rk::UI::readstr();
}

