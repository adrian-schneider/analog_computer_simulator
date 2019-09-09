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

# Initialize a number n of elements.
# Call before anything else from this module.
sub initElements {
  my $n = shift;
  @accumulator = (0.0) x $n;
  @error = (0) x $n;
  @errorval = (0.0) x $n;
}

# { } = limit(idx, v)
# err[idx] := 0
# v := a[idx] > (range_hi + range_tol) -> err[idx] := 1; 
#                                         erv[idx] := a[idx]; range_hi
#      a[idx] < (range_hi - range_tol) -> err[idx] := 1;
#                                         erv[idx] := a[idx]; range_lo
#      1 -> a[idx]
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

# Make integrators to load ic at next time step.
sub intStart {
  $load_ic  = 1;
}

# Output a status of elements idx0 to idx1.
sub status {
  my ($idx0, $idx1) = @_;
  for (my $i = $idx0; $i <= $idx1; $i++) {
    printf("%3d %1s %7.3f\n", $i, $error[$i]?'E':' ', $errorval[$i]);
  }
}

# Return a true value if any element in idx0 to idx1 is
# in error.
# e := 0
# idx0<=idx<=idx1:
#   err[idx] -> e := 1
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

# Set a simulated coefficient "potentiometer".
# Pots have names instead of index numbers.
# coef[name] := v
# <- v
sub setCoef {
  my ($name, $v) = @_;
  $coef{$name} = $v;
  return $v;
}

# Return the value of a coefficient "potentiometer".
# <- coef[name]
sub coef {
  my $name = shift;
  return $coef{$name};
}

# Execute one time step of a summer.
# The summer is actually time-invariant.
# a[idx] := -sp
# <- { idx }
sub summer {
  my ($idx, $sp) = @_;
  $accumulator[$idx] = -$sp;
  return limit($idx);
}

# Execute one time step of a multiplier.
# The multiplier is actually time-invariant.
# a[idx] := (in1p - in1n) * (in2p - in2n) / 10.0
# <- { idx }
sub multiplier {
  my ($idx, $in1p, $in1n, $in2p, $in2n) = @_;
  $accumulator[$idx] = ($in1p - $in1n) * ($in2p - $in2n) / 10.0;
  return limit($idx);
}

# Execute one time step of anintegrator.
# a[idx] := a[idx] - sp/time_div
# <- { idx }
sub integrator {
  my ($idx, $ic, $sp) = @_;
  if ($load_ic) {
    $accumulator[$idx] = $ic;
    $load_ic = 0;
  }
  $accumulator[$idx] -= $sp / $time_div;
  return limit($idx);
}

# Execute one time step of a comparator.
# The multiplier is actually time-invariant.
# a[idx] := in1 >= in2 -> ref1
#           in2 >  in1 -> ref2
# <- { idx }
sub comparator {
  my ($idx, $in1, $in2, $ref1, $ref2) = @_;
  $accumulator[$idx] = ($in1 >= $in2)?$ref1:$ref2;
  return limit($idx);
}

1;
