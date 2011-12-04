package WWW::Scripter::Plugin::JavaScript::V8;

use strict;
use warnings;
use HTML::DOM::Interface ':all';
use JavaScript::V8;

use Data::Dumper;
our $VERSION = '0.01';

sub new {
	my ($class, $scripter) = @_;
	my $self = {cntx => JavaScript::V8::Context->new()};
	
	my @methods = grep !/^_/ && $WWW::Scripter::WindowInterface{$_}&METHOD, 
		keys %WWW::Scripter::WindowInterface;
	foreach my $method (@methods) {
		if ($WWW::Scripter::WindowInterface{$method}&TYPE == NUM) {
			$self->{cntx}->bind($method => sub {
				0+$scripter->$method(@_);
			});
		}
		else {
			$self->{cntx}->bind($method => sub {
				$scripter->$method(@_);
			});
		}
	}
	
	my $create_prop_getter = $self->{cntx}->eval(
		'0,function(p,f){__defineGetter__(p, function(){return f()})}'
	);
	my $create_prop_setter = $self->{cntx}->eval(
		'0,function(p,f){__defineSetter__(p, function(v){f(v)})}'
	);
	my @props = grep !/^_/ && !($WWW::Scripter::WindowInterface{$_}&METHOD),
		keys %WWW::Scripter::WindowInterface;
	
	foreach my $property (@props) {
		$create_prop_getter->($property, sub{
			$scripter->$property;
		});
		
		unless ($WWW::Scripter::WindowInterface{$property}&READONLY) {
			$create_prop_setter->($property, sub {
				$scripter->$property(@_);
			});
		}
	}
	
	bless $self, $class;
}

sub bind_classes {
	my ($self, $classes) = @_;
}

sub eval {
	my ($self, $code, $url, $line) = @_;
	#$self->{cntx}->bind(print => sub{print @_});
	#$self->{cntx}->eval("print(typeof document)");
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WWW::Scripter::Plugin::JavaScript::V8 - Perl extension for blah blah blah

=head1 SYNOPSIS

  use WWW::Scripter::Plugin::JavaScript::V8;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WWW::Scripter::Plugin::JavaScript::V8, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Oleg G, E<lt>oleg@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Oleg G

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
