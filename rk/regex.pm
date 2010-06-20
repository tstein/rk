#!/usr/bin/perl

package rk::regex;

use warnings;
use strict;

our($last_regex, @tests, %results);

sub addTest {
    push(@tests, shift);
}

sub runTests {
    $last_regex = shift;
    my $num_passed = 0;

    foreach my $test (@tests) {
        if ($test =~ $last_regex) {
            $results{$test} = 1;
            ++$num_passed;
        } else {
            $results{$test} = 0;
        }
    }

    return $num_passed;
}

1;

