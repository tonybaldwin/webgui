package WebGUI::Form::Url;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Text';
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Style;

=head1 NAME

Package WebGUI::Form::Url

=head1 DESCRIPTION

Creates a URL form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the superclass for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 2048. Determines the maximum number of characters allowed in this field.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=> 2048
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("478","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Parses the posted value and tries to make corrections if necessary.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $session{req}->param($self->{name});
     	if ($value =~ /mailto:/) {
                return $value;
        } elsif ($value =~ /^([A-Z0-9]+[._+-]?){1,}([A-Z0-9]+[_+-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i) {
                return "mailto:".$value;
        } elsif ($value =~ /^\// || $value =~ /:\/\// || $value =~ /^\^/) {
                return $value;
        }
        return "http://".$value;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a URL field.

=cut

sub toHtml {
        my $self = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/addHTTP.js',{ type=>'text/javascript' });
	$self->{extras} .= ' onBlur="addHTTP(this.form.'.$self->{name}.')"';
	return $self->SUPER::toHtml;
}

1;

