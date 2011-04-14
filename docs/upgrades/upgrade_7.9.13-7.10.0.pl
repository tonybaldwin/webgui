#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.10.0';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addAddonsToAdminConsole($session);
createThingyDBColumns($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Creates new column in tables for Thingy_fields and Thingy_things
sub createThingyDBColumns {
    my $session = shift;
    print "\tAdding db. columns Thingy_fields.isUnique and Thingy_things.maxEntriesTotal.." unless $quiet;
    # and here's our code

    my %tfHash =  $session->db->quickHash("show columns from Thingy_fields where Field='isUnique'");
    my %ttHash =  $session->db->quickHash("show columns from Thingy_things where Field='maxEntriesTotal'");

    unless ( $tfHash{'Field'}) { $session->db->write("alter table Thingy_fields add isUnique int(1) default 0"); }
    unless ( $ttHash{'Field'}) { $session->db->write("alter table Thingy_things add maxEntriesTotal int default null"); }

    print "DONE!\n" unless $quiet;
}





#----------------------------------------------------------------------------
# Describe what our function does
sub addAddonsToAdminConsole {
    my $session = shift;
    print "\tAdd the Addons icon to the Admin Console... " unless $quiet;
    # and here's our code
    $session->config->addToHash('adminConsole', 
    addons => {
      icon    => "addons.png",
      uiLevel => 1,
      group   => "12",
      url     => "http://www.webgui.org/addons",
      title   => "Addons"
    });
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}


# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    print "\tUpgrading package $file\n" unless $quiet;
    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        $node->importPackage( $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } );
    };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
