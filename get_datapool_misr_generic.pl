#!/usr/bin/perl

#  File: get_datapool_misr.pl
#  Version 1.0; 2016-03-13
#     Initial release by Linda Hunt, under the name 'download_data.pl'.
#  Version 1.1; 2017-11-25
#     Change script name to 'get_misr_datapool.pl', add in-line documentation.
#  Version 1.2; 2019-01-07
#     Change script name to 'get_datapool_misr.pl', add this folder to the
#     PATH defined in .bash_profile.
#  Version 1.3; 2019-01-15
#     Add commands to print the local date and time at the start and at the
#     end of the download operation.

#  Purpose:
#     This script, used in conjunction with a text file generated by
#     the IDL program 'mk_ftp_datapool_misr', retrieves a set of
#     MISR data files for a specified Path and the set of Orbits between
#     two specified dates.

#  Usage:
#     1. Set or update the email address on line 53.
#     2. Save this Perl script in a folder that is on the OS PATH.
#     3. Ensure that this file is executable.
#     4. Open a Terminal window and issue the following 2 commands:
#  cd [path to the FTP script file]
#  perl ~/Codes/Scripts/perl/get_datapool_misr.pl
#     "FTPscript_datapool_MISR_Pxxx_Oyyyyyy-Ozzzzzz_YYYY-MM-DD.txt"
#        where the argument to this script is the name of the ftp file
#        generated by the IDL program 'mk_ftp_datapool_misr.pro', xxx
#        is the desired Path number, yyyyyy and zzzzzz are the first and
#        last Orbits to be downloaded, and YYYY-MM-DD is the date of
#        creation of the FTP script file.

#  Load neded modules:
use Net::FTP;
use Cwd;

#  Read the script's argument list, open the first one as a text file
#  (this file is expected to be contain a list of ftp commands to download
#  MISR data files), read the content into an array, and close the file:
$filelist = $ARGV[0];
open(IN,$ARGV[0]) || die "Error 100: Can't open command file list $ARGV[0] $!";
@lines = <IN>;
close(IN);

print "Starting ftp \n";
#  Log in to the NASA Langley Data Pool ftp site:
$ftp = Net::FTP->new("l5ftl01.larc.nasa.gov");
die "Error 200: Couldn't connect to Data Pool ftp site!" unless $ftp;
$code = $ftp->code;
$message = $ftp->message;
print "Connect: [$code] [$message]\n";

#  Login and set the transfer mode to binary:
$status = $ftp->login('ftp','your_email_address@your_institution');
$code = $ftp->code;
$message = $ftp->message;
print "Login: [$status] [$code] [$message]\n";
$ftp->binary;

#  Print the date and time at the start of the download process:
$datestring = localtime();
print "Local date and time at start of the download process: $datestring\n";

#  Execute each command contained in the input file:
$idx = 0;
foreach $line(@lines) {
#  Remove the newline character at the end of the line:
    chomp($line);
#  The very first line of the input file should contain the path
#  to the folder that will be used for downloading data:
    if ($idx == 0) {
		if (-e $line) {
			chdir($line);
			print "Writing ftp files to $line\n";
		} else {
	    	print "Local directory $line does not exist\n";
	    	system ("mkdir $line") &&
         die "Error 210: Can't create directory $line";
		}
    } else {
      ($cmd, $obj) = split(/\s+/,$line);
      print "$cmd $obj\n";
	  if ($cmd =~ 'cd') {
	      $status = $ftp->cwd($obj);
	      $code = $ftp->code;
	      $message = $ftp->message;
		  print "cd to $obj: [$status] [$code] [$message]\n";
	  }
	  if ($cmd =~ 'get') {
	  	 $ftp->get($obj);
	 	 $code = $ftp->code;
	  	 $message = $ftp->message;
	  	 print "Get of $obj: [$status] [$code] [$message]\n";
	  }
    }
    $idx++;
}

#  Print the date and time at the end of the download process:
$datestring = localtime();
print "Local date and time at end of the download process: $datestring\n";

$ftp->quit();
print "ftp of $filelist complete\n";
