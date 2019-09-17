package AnalogSim;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(
  initElements limit intStart status error setCoef coef summer multiplier integrator comparator
);
%EXPORT_TAGS = (
  Basic  => [qw(&initElements &limit &intStart &status &error &setCoef &coef
    &summer &multiplier &integrator &comparator)]
);

use constant RANGE_TOL_DFT =>   0.05;
use constant RANGE_HI_DFT  =>  10.0;
use constant RANGE_LO_DFT  => -10.0;
use constant TIME_DIV_DFT  => 100;

my @accumulator = ();
my @error = ();
my @errorval = ();
my %coef = ();
my $load_ic  = 1;

our $range_hi = RANGE_HI_DFT;
our $range_lo = RANGE_LO_DFT;
our $range_tol = RANGE_TOL_DFT;
our $time_div = TIME_DIV_DFT;

# Initialize the simulator to provide a given number n of
# computational elements.
# The simulator allocates storage space to keep the state of intStart
# computational elements.
#
# *** Call this procedure before anything else from this module.
sub initElements {
  my $n = shift;
  @accumulator = (0.0) x $n;
  @error = (0) x $n;
  @errorval = (0.0) x $n;
}

# { idx } means the limited value of the accumulator of element
# number idx.
# If the accumulator value lies outside the specified range plus a
# tolerance band, the respective low or high range value is returned.
# The function also sets the error status and error value according to the
# evaluation result.
#
# v := a[idx]
# v := v > (range_hi + range_tol) ? err[idx] := 1,
#                                   erv[idx] := v, range_hi
#      v < (range_lo - range_tol) ? err[idx] := 1,
#                                   erv[idx] := v, range_lo
# <- v
sub limit {
  my $idx = shift;
  #return $accumulator[$idx];

  my $v = $accumulator[$idx];
  if ($v > ($range_hi + $range_tol)) {
    $error[$idx] = 1;
    $errorval[$idx] = $v;
    $v = $range_hi;
  }
  elsif ($v < ($range_lo - $range_tol)) {
    $error[$idx] = 1;
    $errorval[$idx] = $v;
    $v = $range_lo;
  }
  return $v;
}

# Reset the simulator so the integrators load ic at the next time step.
# On a real analog computer, this is equivalent to pushing the
# "Load Initial Conditions"-button.
sub intStart {
  $load_ic  = 1;
}

# Output the error status and error value of the computational elements
# number idx0 ro idx1.
sub status {
  my ($idx0, $idx1) = @_;
  for (my $i = $idx0; $i <= $idx1; $i++) {
    printf("%3d %1s %7.3f\n", $i, $error[$i]?'E':' ', $errorval[$i]);
  }
}

# Check a range of computational elements for an error Condition.
# Return a true value if any computational element number idx0 to idx1 is
# in error.
#
# e := 0
# idx0 <= idx <= idx1:
#   err[idx] ? e := 1
# <- e
sub error {
  my ($idx0, $idx1) = @_;
  my $e = 0;
  for (my $i = $idx0; $i <= $idx1; $i++) {
    if ($error[$i]) {
      $e = 1;
      last;
    }
  }
  return $e;
}

# Set a simulated coefficient virtual potentiometer.
# The previous value is returned.
#
# *** Potentiometers are referenced by name rather than an index number.
#
# p := coef[name]
# coef[name] := v
# <- p
sub setCoef {
  my ($name, $v) = @_;
  my $p = $coef{$name};
  $coef{$name} = $v;
  return $p;
}

# Return the value of a coefficient virtual potentiometer.
# <- coef[name]
sub coef {
  my $name = shift;
  return $coef{$name};
}

# Set the accumulator to the negative value of a summing point.
# The summing point value is usually the result of an arithmetic expression.
# The limited new accumulator value is returned.
#
# a[idx] := -sp
# <- { idx }
sub summer {
  my ($idx, $sp) = @_;
  $accumulator[$idx] = -$sp;
  return limit($idx);
}

# Set the accumulator to the negative value of a summing point.
# The summing point value is usually the result of an arithmetic expression.
# The limited new accumulator value is returned.
#
# a[idx] := (in1p - in1n) * (in2p - in2n) / 10.0
# <- { idx }
sub multiplier {
  my ($idx, $in1p, $in1n, $in2p, $in2n) = @_;
  $accumulator[$idx] = ($in1p - $in1n) * ($in2p - $in2n) / 10.0;
  return limit($idx);
}

# Set the accumulator to a fraction of  the negative value of a summing point.
# The fraction is defined as 1/time_div.
# This represents a single time step of the simulation of an integration over
# time.
# The summing point value is usually the result of an arithmetic expression.
# The limited new accumulator value is returned.
#
# load_ic = 1 ? a[idx] := ic
# load_ic = 0 ? a[idx] := a[idx] - sp/time_div
# <- { idx }
sub integrator {
  my ($idx, $ic, $sp) = @_;
  if ($load_ic) {
    $accumulator[$idx] = $ic;
    $load_ic = 0;
  }
  else {
    $accumulator[$idx] -= $sp / $time_div;
  }
  return limit($idx);
}

# Set the accumulator to one of two reference values, depending on the relation
# between two given input values.
# The limited new accumulator value is returned.
#
# a[idx] := in1 >= in2 ? ref1
#           in2 >  in1 ? ref2
# <- { idx }
sub comparator {
  my ($idx, $in1, $in2, $ref1, $ref2) = @_;
  $accumulator[$idx] = ($in1 >= $in2)?$ref1:$ref2;
  return limit($idx);
}

1;
