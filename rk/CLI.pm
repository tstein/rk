#!/usr/bin/perl

package rk::CLI;

use warnings;
use strict;
use Switch;
use rk::regex;

our(@history);



sub addRE {
    push (@rk::regex::regexen, shift)
}



sub addTest {
    push (@rk::regex::tests, shift);
}



sub extractTest {
    my $cmd = shift;
    if ($cmd =~ /^\/test\s+(.*)$/) {
        return $1;
    }
}



sub parse {
    # Parse may need to pass back several different kinds of information, so we
    # return a hash with the following key/value pairs:
    #   'type' => string describing what command was entered. Always defined.
    #       Possible values:
    #       error
    #       regex
    #       new_test
    #       exit
    #   'arg' => A string for unary commands; an array for n-ary ones. Undefined
    #       for nullary commands.
    #   'details' => For commands with more than one possible outcome, a scalar
    #       describing the results. For errors, a string describing what went
    #       wrong. Undefined otherwise.
    my %ret;

    my $cmd = shift;
    $cmd =~ s/^\s*(.*?)\s*$/$1/;
    push(@history, $cmd);
    
    if ($cmd and $cmd !~ /^\//) {
        push(@rk::regex::regexen, $cmd);
        $ret{'type'} = 'regex';
        $ret{'arg'} = $cmd;
        return %ret;
    }

    switch($cmd) {
        case /^\/test\s/ {
            # Strange - regexes inside cases is apparently bad. extractTest
            # works around this.
            my $new_test = extractTest($cmd);
            if ($new_test) {
                addTest($new_test);
                $ret{'type'} = 'new_test';
                $ret{'arg'} = $new_test;
            } else {
                $ret{'type'} = 'error';
                $ret{'details'} = 'Cannot add an empty test.';
            }
        }

        case /^\/exit$/         {
            $ret{'type'} = 'exit';
        }

        else                    {
            $ret{'type'} = 'error';
            $ret{'details'} = 'Invalid command.';
        }
    }

    return %ret;
}

1;

