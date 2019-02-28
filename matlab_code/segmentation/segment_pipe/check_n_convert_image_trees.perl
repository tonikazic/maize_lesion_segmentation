#!/usr/bin/perl

# this is /athe/d/derek/code/image_processing/segmentation/segment_pipe/check_n_convert_image_trees.perl 

# given two input directories, the first the directory of the raw image files and the
# second the root of the destination directory of the tiffs, and a timestamp passed from 
# batch_segment_call.m for unambiguous labelling:
#
#     see if the tiff subdir and the list of fully qualified file names have been created:
#          the assumption is that if the dir is there and the count of files is one greater
#          than in the image directory, then we're ok
#
#     otherwise, call dcraw.c (compiled) and generate the tiffs; then generate the file list.
#          and enter all this in a conversion log file
#
#
# call is ./check_n_convert_image_trees.perl IMAGE_DIR TIFF_ROOT TIMESTAMP
#
# where IMAGE_DIR is the crop/camera/day-specific suffix of /athe/c/maize/images, 
# WITHOUT the left-most /.
#
# Neither argument needs quotes at the command line.
#
# for example,
#
# ./check_n_convert_image_trees.perl 16r/gimmel/27.7 /athe/c/maize/analysis_images/tiffs/ 11111111

# see /athe/c/maize/crops/ablate_crops_offspring.perl for some directory handling stuff

 
use File::Path qw(make_path);
use File::Find;
use File::Find::Rule;


use lib qw(../../../../../../c/maize/label_making/);
use Typesetting::DefaultOrgztn;
use Typesetting::MaizeRegEx;



$image_dir = $ARGV[0];
$tiff_root = $ARGV[1];
$timestamp = $ARGV[2];


# these should never happen when called from batch_segment_call.m,
# but just to be safe . . . 

if ( $image_dir =~ /^\//) { ($image_dir) =~ s/^\///;  }
if ( $tiff_root !~ /\/$/) { $tiff_root = $tiff_root . "/"; }

$full_image_dir = $image_root . $image_dir;
$output_dir = $tiff_root . $image_dir;
$analysis_dir = $tiff_root;
$analysis_dir =~ s/tiffs\///;
$log_file = $analysis_dir . "conversion_log.org";

$today = `date`;
chomp($today);


# print "t: $today\ni: $image_dir\nt: $tiff_root\nts: $timestamp\nf: $full_image_dir\no: $output_dir\na: $analysis_dir\nl: $log_file\n";



# thanks to the perl monks for the open/read/close dir and grep trick
# http://www.perlmonks.org/?node_id=606763
#
# and more thanks to the monks for a better way to get around the fact you
# can't combine globs and regular expressions, the way I'd like to here:
#
# @nef_files = grep { -f glob("${full_image_dir}/*.NEF") } readdir $dh  or die "can't open input dir $full_image_dir";
#
# http://www.perlmonks.org/?node_id=955536
#
# and this works very nicely.
#
# Kazic, 25.9.2016


opendir $dh, $full_image_dir;
@nef_files = find( file => name => qr/NEF/i, in => "$full_image_dir/" ) or exit 1;
closedir $dh or exit 2;
$images = $#nef_files + 1;

# foreach $file ( @nef_files ) { print "$file\n"; }
# print "c: $images\n";





# we assume the directory must exist for this to work, so if it
# doesn't, then we set the number of files in it to 0.
#
# However, to be safe, we make sure that we count what's there.


if ( -d $output_dir ) {
        opendir $dh, $output_dir;
        @tif_files = find( file => name => qr/tiff/, in => "$output_dir/" );
        closedir $dh or exit 3;
        $tiff_files = $#tif_files + 1;
        }

else { 
       $tiff_files = 0; 
       make_path($output_dir);
       }




if ( $images != $tiff_files ) {

        $dc_cmd = "./dcraw -c -T ";



# open conversion log file, print header, and then data on conversion

        open(LOG,">>$log_file");        

        print LOG "* Image Conversion on $today for batch_segment_call.m timestamp $timestamp\n\n"; 
        print LOG "** Conversions Performed\n\n";


# foreach file in @nef_files, construct the input and output names and call dcraw

        foreach $file (@nef_files) {
                ($stem) = $file =~ /(DSC_\d{4})\.NEF$/;
                $output_file = $output_dir . "/" . $stem . ".tiff";

#                print "s: $stem o: $output_file\n";



# call compiled dcraw on each file and output
#
# check to see if dcraw can work on an entire subdirectory and output results to 
# another subdirectory


                if ( !-e $output_file ) {
                        $cmd = $dc_cmd . $file . " > " . $output_file;
                        system($cmd);
		        print LOG "$cmd\n";
		        }
                }


# close conversion log file

        print LOG "\n\n\n";
        close(LOG);
        }








# return status signalling success back to batch_segment_call.m

exit 0;
