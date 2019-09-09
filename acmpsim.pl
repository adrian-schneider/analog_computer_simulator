#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use lib "./";
use AnalogSim qw(:Basic);
use SvgGraph qw(:Basic :Axis :Shapes);

sub show_help {
  print "$0\n";
  exit(0);
}

GetOptions(
#  "header!"    => \$arg_header,
#  "help"       => \&show_help,
#  "trigger=s"  => \$arg_trigger,
#  "parse-wr=s" => \$arg_parse_wr
)
or die "Error in command line arguments.\n";

newPage;
setChrSize(SvgGraph::MEDIUM);
plot(100, 50);
text("AnalogSim Circle Test", SvgGraph::NOMOVE);
setChrSize(SvgGraph::TINY);
axis(100, 600, 500, 0, -10.0, 10.0, 2.5, "%.1f", 1);
axis(100, 100, 500, 2, -10.0, 10.0, 2.5, "%.1f", 1);
mapDef(-10.0, -10.0, 10.0, 10.0, 100, 100, 599, 599);
plotPoint;
plot(mapX(0.0), mapY(0.0));
plot(mapX(1.0), mapY(1.0));
setLineStyle(SvgGraph::SMALLDASH);
setColor(SvgGraph::GREEN);
ellipse(mapX(0.0), mapY(0.0), mapX(10.0)-mapX(0.0), mapY(10.0)-mapY(0.0));
plotLine;
setLineStyle(SvgGraph::FULL);
setColor(SvgGraph::WHITE);

initElements(2);
intStart;

$AnalogSim::time_div = 100; # Test with a small time div.
#$AnalogSim::range_tol = 0.0;

my $j = 0.0;
my $k = 0.0;
my $i = 0;
for (my $i = 0; $i <= 5*$AnalogSim::time_div; $i++) {

#                 indx  ic         sp
  $k = integrator(0,    $AnalogSim::range_lo, -$j);

#                 indx  ic         sp
  $j = integrator(1,    0.0,       $k);

  #printf "%5i,%7.3f,%7.3f\n", $i, $k, $j;
  !($i % 10) && plot(mapX($k), mapY($j));
}
error(0, 1) && status(0, 1);

endPage;
