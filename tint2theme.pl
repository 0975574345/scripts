#!/usr/bin/env perl
use strict;
use autodie;
use File::Copy;

# dbbolton
# danielbarrettbolton at gmail

# Path to your tint2rc files
my $path = "$ENV{HOME}/.config/tint2/";
chdir $path;

# The tint2rc location
my $rcfile = "$ENV{HOME}/.config/tint2/tint2rc";
my $backup = "$ENV{HOME}/.config/tint2/tint2rc_backup";;

# tint2's process ID, if running
my $tintpid = `pidof tint2`;

# Find available files
opendir(my $dh, $path);
my @files = sort(readdir($dh));

my $i = 0;
my $del = 0;
for ( @files ) {
    unless ( -f ) {
        delete $files[$i];
        $del++;
    }
    $i++;
}

$i=0;
print "Available config files: \n";
for ( @files ) {
    if ( $_ ) {
        print "$i\t$_\n";
        $i++;
    }
}

# Ask which theme file to use
my $newtheme;
sub getnew {
  print "\nEnter theme number: ";
  chomp( my $n = <> );
  $n += $del;
  return $n;
}

# Make sure the name is ok
my $usenew;
sub checkfile {
 if (-e "$path/$newtheme" && -r "$path/$newtheme" ) {
    print "File is OK.\n";
 }
else {
    print "\nEither the specified file does not exist in the theme directory, or you do 
not have access to it.\n";
    $newtheme = getnew();
    checkfile();
 }
}

sub verify {
    print "Really use theme \"$newtheme\" ? (y/n) ";
    chomp( $usenew = <> );
    if ( $usenew =~ /[y1]/i ) {
        writefile();
    }
    elsif ( $usenew =~ /[n0]/i ) {
        print "Aborting.\n";
        exit;
    }
    else {
        print "Invalid response. Type 'y' or 'n'.\n";
        verify();
    }
}

sub starttint {
    if ( $tintpid ) {
        system "kill $tintpid";
}

    defined( my $pid = fork );
        unless ( $pid ) {
        close( STDIN );
        close( STDOUT);
        close( STDERR);
        exec "tint2 -c $rcfile";
        exit 0;
    }
}

sub writefile {
    unless ( $newtheme eq "tint2rc" ) {
        if ( -e $rcfile ) {
            print "Backing up tint2rc to \n  '$backup' ...\n";
            move( $rcfile, $backup );
        }
        print "Writing '$newtheme' to '$rcfile' ...\n";
        copy( "$path/$newtheme", $rcfile );
    print "(Re)starting tint2 ... \n";
    }
    else {
        print "Not overwriting tint2rc with '$newtheme'";
    }
    starttint();
}

my $index = getnew();
$newtheme = $files[$index];
checkfile();
verify();
