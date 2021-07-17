# Developed by Nalin Ahuja, nalinahuja

use strict;
use warnings;
use File::Basename;

# End Header-----------------------------------------------------------------------------------------------------------------------------------------------------------

sub max {
  # Get Numerical Arguments
  my ($a, $b) = @_;

  # Return Maximum Argument Value
  return ($a > $b ? $a : $b);
}

sub lcs {
  # Get String Arguments
  my ($ms, $ns) = @_;

  # Get String Lengths
  my $ml = length($ms);
  my $nl = length($ns);

  # Initialize Tabulation Array
  my @tbl = ();

  # Populate Table With Default Values
  foreach (my $i = 0; $i < ($nl + 1) * ($ml + 1); $i++) {
    push(@tbl, 0);
  }

  # Iterate Over Table Rows
  for (my $i = 0; $i < $ml + 1; $i++) {
    # Iterate Over Table Columns
    for (my $j = 0; $j < $nl + 1; $j++) {
      # Update Table
      if ($i == 0 or $j == 0) {
        $tbl[(($nl + 1) * $i) + $j] = 0;
      } elsif (substr($ms, $i - 1, 1) eq substr($ns, $j - 1, 1)) {
        $tbl[(($nl + 1) * $i) + $j] = $tbl[(($nl + 1) * ($i - 1)) + ($j - 1)] + 1;
      } else {
        $tbl[(($nl + 1) * $i) + $j] = max($tbl[(($nl + 1) * ($i - 1)) + $j], $tbl[(($nl + 1) * $i) + ($j - 1)]);
      }
    }
  }

  # Return Longest Common Subsequene
  return $tbl[-1];
}

# End Subroutines------------------------------------------------------------------------------------------------------------------------------------------------------

# Get Commandline Arguments
my $regex = $ARGV[0];
my @paths = @ARGV[1 .. $#ARGV];

# Initalize Similarity Array
my @similarity = ();

# Iterate Over Paths
foreach my $path (@paths) {
  # Get Path Basename
  my $bname = basename($path);

  # Calculate Subsequence Length
  my $subl = lcs($regex, $bname);

  # Calculate String Length Delta
  my $ldel = abs(length($regex) - length($bname));

  # Push Result To Similarity Array
  push(@similarity, {path => $path, subl => $subl, ldel => $ldel});
}

# Sort Similiarity Array Using Comparator
@similarity = reverse sort {
                            $a->{subl} <=> $b->{subl} ||
                            $b->{ldel} <=> $a->{ldel}
                           } @similarity;

# Return Similarity Scores
foreach my $score (@similarity){
  # Print Result
  print("@{$score}{qw(path)}", "\n");
}

# End Main-------------------------------------------------------------------------------------------------------------------------------------------------------------
