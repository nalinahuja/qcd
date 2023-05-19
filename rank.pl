# Developed by Nalin Ahuja, nalinahuja

use strict;
use warnings;
use File::Basename;

# End Imports---------------------------------------------------------------------------------------------------------------------------------------------------------

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

  # Find Longest Common Subsequence
  for (my $i = 0; $i < $ml + 1; $i++) {
    for (my $j = 0; $j < $nl + 1; $j++) {
      if ($i == 0 or $j == 0) {
        $tbl[(($nl + 1) * $i) + $j] = 0;
      } elsif (substr($ms, $i - 1, 1) eq substr($ns, $j - 1, 1)) {
        $tbl[(($nl + 1) * $i) + $j] = $tbl[(($nl + 1) * ($i - 1)) + ($j - 1)] + 1;
      } else {
        $tbl[(($nl + 1) * $i) + $j] = max($tbl[(($nl + 1) * ($i - 1)) + $j], $tbl[(($nl + 1) * $i) + ($j - 1)]);
      }
    }
  }

  # Return Longest Common Subsequence
  return $tbl[-1];
}

sub lci {
  # Get String Arguments
  my ($ms, $ns) = @_;

  # Get String Lengths
  my $ml = length($ms);
  my $nl = length($ns);

  # Initialize Latest Index
  my $li = -1;

  # Find Index Of Latest Character
  for (my $i = 0; $i < $ml; $i++) {
    $li = max($li, index($ns, substr($ms, $i , 1)));

    # Break Loop If Latest Index Equals Target String Length
    if ($li == $nl) {
      last;
    }
  }

  # Check If Latest Index Was Updated
  if ($li == -1) {
    # Set Latest Index To Maximum Value
    $li = 256
  }

  return $li;
}

# End Subroutines-----------------------------------------------------------------------------------------------------------------------------------------------------

# Get Commandline Arguments
my $regex = $ARGV[0];
my @paths = @ARGV[1 .. $#ARGV];

# Initalize Path Similarity Array
my @path_similarity = ();

# Iterate Over Paths
foreach my $path (@paths) {
  # Get Path Basename
  my $bname = basename($path);

  # Calculate Subsequence Length
  my $lcs = lcs($regex, $bname);

  # Determine Latest Character Index
  my $lci = lci($regex, $bname);

  # Calculate String Length Delta
  my $lnd = abs(length($bname) - length($regex));

  # Push Info To Path Similarity Array
  push(@path_similarity, {path => $path, lcs => $lcs, lci => $lci, lnd => $lnd});
}

# Sort Path Similarity Array Using Comparator
@path_similarity = reverse sort {
                            $a->{lcs} <=> $b->{lcs} ||
                            $b->{lci} <=> $a->{lci} ||
                            $b->{lnd} <=> $a->{lnd}
                          } @path_similarity;

# Return Path Rank
foreach my $path_info (@path_similarity){
  # Print Path
  print("@{$path_info}{qw(path)}", "\n");
}

# End Main------------------------------------------------------------------------------------------------------------------------------------------------------------
