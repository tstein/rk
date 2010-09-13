#!/usr/bin/perl

package rk::regex;

use warnings;
use strict;

our(@regexen, @tests, %results);

sub addTest {
    push(@tests, shift);
}

sub testRE {
    my $re = shift;
    my $num_passed = 0;

    foreach my $test (@tests) {
        if ($test =~ $re) {
            $results{$test} = 1;
            ++$num_passed;
        } else {
            $results{$test} = 0;
        }
    }

    return $num_passed;
}

1;

