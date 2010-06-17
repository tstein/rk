#!/usr/bin/perl

use warnings;
use strict;
use Switch;

my($cmdline, $cmd, $arg, $continue);
my $regex;
my @tests;



sub runRE {
    $regex = $_[0];
    print("Running regex: $regex\n");
    foreach my $test (@tests) {
        if ($test =~ $regex) {
            print("\tPASS: ");
        } else {
            print("\tFAIL: ");
        }
        print("$test\n");
    }
}

sub addTest {
    unless ($_[0]) {
        print("Cannot add empty test.\n");
        return;
    }

    push(@tests, $_[0]);
    print("Added test: $_[0]\n");
}

sub listTests {
    print("Tests currently loaded:\n");
    foreach my $test (@tests) {
        print("\t$test\n");
    }
}

sub exitRK {
    exit($_[0]);
}

$continue = "true";
$cmdline = "";
while ($continue) {
    print("> ");

    $cmdline = readline();

    unless ($cmdline =~ /^([rtle])(?:\s+(.*))?$/) {
        print("Invalid command.\n");
        next;
    }

    $cmd = $1;
    $arg = $2;

    switch ($cmd) {
        case "r"    { runRE($arg) }
        case "t"    { addTest($arg) }
        case "l"    { listTests() }
        case "e"    { exitRK(0) }
    }
}

