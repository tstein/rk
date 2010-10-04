#!/usr/bin/perl
# vim:filetype=perl foldmethod=marker autoindent expandtab shiftwidth=4

package rk::UI;

use warnings;
use strict;
use Curses;
use Switch;
use rk::CLI;

my($status_bar, $left_pane, $right_pane, $command_bar);
my @windows;
# The next two variables are used to store the offsets within the history and
#   test arrays that are currently being shown.
my($lp_pos, $rp_pos) = (0,0);
my $message;



sub cleanup {
    for my $window (@windows) {
        $$window->delwin();
    }
    clear();
    endwin();
}



sub resetUI {
    cleanup();
    initScreen();
}



sub showMessage {
    my($lp_y, $message, $num_spaces);
    $left_pane->getmaxyx($lp_y, my $unused);

    $message = shift;
    $num_spaces = $lp_y - 4 - length($message);
    $left_pane->addstr($lp_y - 2, 1, $message . (' ' x $num_spaces));
}



sub newBoxedWin {
    my $win = newwin(shift, shift, shift, shift);
    $win->box(0, 0);
    $win->refresh();
    return $win;
}



sub resetCursor {
    my ($cb_x, $cb_y);
    $command_bar->getmaxyx($cb_y, $cb_x);
    $command_bar->move($cb_y - 2, 1);
    $command_bar->refresh();
}



sub resetInput {
    my($cb_x, $cb_y);
    $command_bar->getmaxyx($cb_y, $cb_x);

    for (my $i = 1; $i < $cb_x - 1; ++$i) {
        $command_bar->addch($cb_y - 2, $i, ' ');
    }
    resetCursor();
}



sub redrawHistory {
    my($lp_x, $lp_y, $regex, $tests_passed, $results, $line, $hist_pos, $hist_width, $num_spaces);
    $left_pane->getmaxyx($lp_y, $lp_x);
    for (my $i = 1; $i < $lp_y - 3; ++$i) {
        $line = '';
        $hist_pos = $i + $lp_pos;

        # Draw the current history line, with the results of that regex.
        if ($rk::regex::regexen[-$hist_pos]) {
            $regex = $rk::regex::regexen[-$hist_pos];
            $tests_passed = rk::regex::testRE($regex);
            $results  = '(' . $tests_passed;
            $results .= ' / ' . ($#rk::regex::tests + 1) . ')';

            $left_pane->getmaxyx(my $unused, $hist_width);
            $num_spaces = $hist_width - 4 - length($regex) - length($results);
            $line = $regex . (' ' x $num_spaces) . $results;
        }

        # TODO: Make regexes that pass all loaded tests stand out.
        if ($tests_passed && $tests_passed == ($#rk::regex::tests + 1)) {
            #attron(A_BOLD);
        }
        $left_pane->addstr($lp_y - 3 - $i, 1, $line);
        if ($tests_passed && $tests_passed == ($#rk::regex::tests + 1)) {
            #attroff(A_BOLD);
            undef($tests_passed);
        }

        # Draw arrows if there are undrawn lines.
        switch($i) {
            case ($lp_y - 3 - 1)    {
                if ((scalar @rk::regex::regexen)- ($lp_y - 3) - $lp_pos >= 0) {
                    $left_pane->addch($lp_y - 3 - $i, $lp_x - 3, '^');
                } else {
                    $left_pane->addch($lp_y - 3 - $i, $lp_x - 3, ' ');
                }
            }
            case (1)    {
                if ($lp_pos > 0) {
                    $left_pane->addch($lp_y - 3 - $i, $lp_x - 3, 'v');
                } else {
                    $left_pane->addch($lp_y - 3 - $i, $lp_x - 3, ' ');
                }
            }
            else {
                $left_pane->addch($lp_y - 3 - $i, $lp_x - 3, ' ');
            }
        }
    }
    $left_pane->refresh();
}



sub redrawTests {
    my($rp_x, $rp_y, $line, $tests_pos);
    $right_pane->getmaxyx($rp_y, $rp_x);
    for (my $i = 0; $i < $rp_y - 2; ++$i) {
        $line = '';
        $tests_pos = $i + $rp_pos;

        # Draw the current test.
        if ($rk::regex::tests[$tests_pos]) {
            $line = $rk::regex::tests[$tests_pos];
        }
        $right_pane->addstr(1 + $i, 1, $line);

        # Pad the line with spaces to overwrite any characters left over from
        #   the last line.
        for (my $j = 1 + length($line); $j < $rp_x - 3; ++$j) {
            $right_pane->addch(1 + $i, $j, ' ');
        }
    }
    $right_pane->refresh();
}



sub resetHistory {
    $lp_pos = 0;
    redrawHistory();
}

sub resetTests {
    $rp_pos = 0;
    redrawTests();
}



sub initScreen {
    initscr();
    cbreak();
    keypad(1);

    my $bar_height = 3;

    $status_bar = newBoxedWin($bar_height, $COLS - 1, 0, 0);
    {   my($bar_x, $bar_y);
        $status_bar->getmaxyx($bar_y, $bar_x);
        $status_bar->addstr(
            $bar_y / 2,
            ($bar_x / 2) - (length($rk::main::banner) / 2),
            $rk::main::banner);
        $status_bar->refresh();
    }
    
    $right_pane = newBoxedWin(
        $LINES - (2 * $bar_height),
        $COLS / 2,
        $bar_height,
        $COLS / 2);

    $left_pane = newBoxedWin(
        $LINES - (2 * $bar_height),
        $COLS / 2,
        $bar_height,
        0);
    {   my($lp_x, $lp_y);
        $left_pane->getmaxyx($lp_y, $lp_x);
        for (my $i = 1; $i < $lp_x - 1; ++$i) {
            $left_pane->addch($lp_y - 3, $i, "-");
        }
    }

    $command_bar = newBoxedWin(
        $bar_height,
        $COLS - 1,
        $LINES - $bar_height,
        0);

    @windows = (\$status_bar, \$left_pane, \$right_pane, \$command_bar);

    resetHistory();
    resetTests();
    resetInput();
}


sub readstr {
    $message = "";

    my($newstr, %parse);
    $command_bar->getstr($newstr);
    chomp($newstr);
    %parse = rk::CLI::parse($newstr);

    switch ($parse{'type'}) {
        case 'exit'     {   cleanup(); exit(0); }
        case 'error'    {   $message = $parse{'details'}; }
        case 'regex'    {   resetHistory(); }
        case 'new_test' {   resetTests(); }
    }

    showMessage($message);
    redrawHistory();
    resetInput();
}

1;

