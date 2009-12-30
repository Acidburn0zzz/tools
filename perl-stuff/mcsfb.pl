# Meiers cpan spec file builder 


use strict;

use CPANPLUS::Backend;
use CPAN::FindDependencies;
use Data::Dumper;
use LWP::Simple;

#use YAML::Tiny;
use YAML::Syck;
use version;



my $name = $ARGV[0];
$name =~ s/::/-/g;

my $cb      = CPANPLUS::Backend->new or die loc("Could not create new CPANPLUS::Backend object");                
my $module = $cb->parse_module( module => $name ) or die "Cannot make a module object out of $name\n";

my $package_name = $module->package_name();

if ( $name ne $package_name) { die "Given Name does not match package name\nSeareched for $name but found $package_name\n"; };

my $yaml_url = "http://search.cpan.org/src/" . $module->author->cpanid . "/" . $name . "-" . $module->package_version . "/META.yml";
print "$yaml_url\n";

my $yaml_file = get($yaml_url);
my $results = Load($yaml_file);


# Merge build_requires and requires in one hash
my %merged = ();
while ( my ($k,$v) = each(%{$results->{'build_requires'}}) ) {
    $merged{$k} = $v;
}
while ( my ($k,$v) = each(%{$results->{'requires'}}) ) {
    $merged{$k} = $v;
}

# Print BuildRequires
foreach my $key (sort keys %merged )  {
		if ( $key eq "perl" ) {
			print "BuildRequires: $key >= " . $merged{$key} . "\n";
		} else {
			print "BuildRequires: perl($key)";
			if ( $merged{$key} != 0 ) {
					print  " >= " . $merged{$key};
			}  
			print "\n";
		}
}

# Print Requires
foreach my $key (sort keys %{$results->{'requires'}} )  {
		if ( $key eq "perl" ) {
			print "Requires: $key >= " .$results->{'requires'}{$key} . "\n";
		} else {
			print "Requires: perl($key)";
			if ( $results->{'requires'}{$key} != 0 ) {
					print  " >= " . $results->{'requires'}{$key};
			}  
			print "\n";
		}
}

print "\n%filter_from_requires /^perl*/d\n";
print "%filter_setup\n";


#foreach my $key (sort keys %{$results->{'recommends'}} )  {
#                if ( $key eq "perl" ) {
#                        print "BuildRequires: $key >= " .$results->{'recommends'}{$key} . "\n";
#                } else {
#                        print "BuildRequires: perl($key)";
#                        if ( $results->{'requires'}{$key} != 0 ) {
#                                        print  " >= " . $results->{'recomemnds'}{$key};
#                        }
#                        print "\n";
#                }
#}
