#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use lib "./";
use AnalogSim qw(:Basic);
use SvgGraphNjs qw(:Basic :Axis :Shapes);

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
setChrSize(SvgGraphNjs::MEDIUM);
plot(100, 50);
text("AnalogSim Circle Test", SvgGraphNjs::NOMOVE);
setChrSize(SvgGraphNjs::TINY);
setColor(SvgGraphNjs::RED);
axis(100, 600, 500, 0, -10.0, 10.0, 2.5, "%.1f", 1);
axis(100, 100, 500, 2, -10.0, 10.0, 2.5, "%.1f", 1);
mapDef(-10.0, -10.0, 10.0, 10.0, 100, 100, 599, 599);
plotPoint;
plot(mapX(0.0), mapY(0.0));
plot(mapX(1.0), mapY(1.0));
setLineStyle(SvgGraphNjs::SMALLDASH);
setColor(SvgGraphNjs::GREEN);
ellipse(mapX(0.0), mapY(0.0), mapX(10.0)-mapX(0.0), mapY(10.0)-mapY(0.0));
plotLine;
setLineStyle(SvgGraphNjs::FULL);
setColor(SvgGraphNjs::WHITE);

initElements(2);
intStart;

$AnalogSim::time_div = 100; # Test with a small time div.
#$AnalogSim::range_tol = 0.0;

my $j = 0.0;
my $k = 0.0;
my $i = 0;
my $lo = $AnalogSim::range_lo;
my $imax = (SvgGraphNjs::PI2 * 0.75)*$AnalogSim::time_div;
for (my $i = 0; $i <= $imax; $i++) {

#                 indx  ic     sp
  $k = integrator(0,    $lo,   -$j);

#                 indx  ic     sp
  $j = integrator(1,    0.0,   $k);

  !($i % ($AnalogSim::time_div / 10)) && plot(mapX($k), mapY($j));
}
plot(mapX($k), mapY($j));
endPage;

error(0, 1) && status(0, 1);
