#!/usr/bin/perl

package rk::UI;
push(@INC, ".");

use warnings;
use strict;
use Curses;
use Switch;
use rk::CLI;

my($status_bar, $left_pane, $right_pane);
my @windows = (\$status_bar, \$left_pane, \$right_pane);
# The next two variables are used to store the offsets within the history and
#   test arrays that are currently being shown.
my($lp_pos, $rp_pos) = (0,0);



sub cleanup {
    for my $window (@windows) {
        $$window->delwin();
    }
    endwin();
    exit(shift);
}



sub newBoxedWin {
    my $win = newwin(shift, shift, shift, shift);
    $win->box(0, 0);
    $win->refresh();
    return $win;
}



sub resetCursor {
    my ($lp_x, $lp_y);
    $left_pane->getmaxyx($lp_y, $lp_x);
    $left_pane->move($lp_y - 2, 1);
    $left_pane->refresh();
}



sub resetInput {
    my($lp_x, $lp_y);
    $left_pane->getmaxyx($lp_y, $lp_x);

    for (my $i = 1; $i < $lp_x - 1; ++$i) {
        $left_pane->addch($lp_y - 2, $i, ' ');
    }
    resetCursor();
}



sub redrawHistory {
    my($lp_x, $lp_y, $regex, $results, $line, $hist_pos);
    $left_pane->getmaxyx($lp_y, $lp_x);
    for (my $i = 1; $i < $lp_y - 3; ++$i) {
        $line = '';
        $hist_pos = $i + $lp_pos;

        # Draw the current history line, with the results of that regex.
        if ($rk::CLI::history[-$hist_pos]) {
            $regex = $rk::CLI::history[-$hist_pos];
            $results = $rk::CLI::results{$regex};
            $line = "$regex ($results)";
        }
        $left_pane->addstr($lp_y - 3 - $i, 1, $line);

        # Pad the line with spaces to overwrite any characters left over from
        #   the last line.
        for (my $j = 1 + length($line); $j < $lp_x - 2; ++$j) {
            $left_pane->addch($lp_y - 3 - $i, $j, ' ');
        }

        # Draw arrows if there are undrawn lines.
        switch($i) {
            case ($lp_y - 3 - 1)    {
                if ((scalar @rk::CLI::history)- ($lp_y - 3) - $lp_pos >= 0) {
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
        for (my $j = 1 + length($line); $j < $rp_x - 2; ++$j) {
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
        $LINES - $bar_height,
        $COLS / 2,
        $bar_height,
        $COLS / 2);

    $left_pane = newBoxedWin(
        $LINES - $bar_height,
        $COLS / 2,
        $bar_height,
        0);
    {   my($lp_x, $lp_y);
        $left_pane->getmaxyx($lp_y, $lp_x);
        for (my $i = 1; $i < $lp_x - 1; ++$i) {
            $left_pane->addch($lp_y - 3, $i, "-");
        }
    }

    resetHistory();
    resetTests();
    resetInput();
}


sub readstr {
    my($newstr, %parse);
    $left_pane->getstr($newstr);
    chomp($newstr);
    %parse = rk::CLI::parse($newstr);

    switch ($parse{'type'}) {
        case 'exit'     {   cleanup(0); }
        case 'regex'    {   resetHistory(); }
        case 'new_test' {   resetTests(); }
    }

    redrawHistory();
    resetInput();
}

1;
