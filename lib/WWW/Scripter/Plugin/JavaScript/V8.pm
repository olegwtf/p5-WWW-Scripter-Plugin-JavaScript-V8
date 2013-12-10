package WWW::Scripter::Plugin::JavaScript::V8;

use strict;
use warnings;
use HTML::DOM::Interface ':all';
use JavaScript::V8;

use Data::Dumper;
our $VERSION = '0.01';

sub new {
	my ($class, $scripter) = @_;
	
	my $cntx = JavaScript::V8::Context->new();
	$cntx->name_global('window');
	
	my $self = {cntx => $cntx};
	
	my @methods = grep !/^_/ && $WWW::Scripter::WindowInterface{$_}&METHOD, 
		keys %WWW::Scripter::WindowInterface;
	
	foreach my $method (@methods) {
		if ($WWW::Scripter::WindowInterface{$method}&TYPE == NUM) {
			$cntx->bind($method => sub {
				0+$scripter->$method(@_);
			});
		}
		else {
			$cntx->bind($method => sub {
				$scripter->$method(@_);
			});
		}
	}
	
	my $prop_getter = $self->{cntx}->eval(
		'0,function(p,f){__defineGetter__(p, function(){return f()})}'
	);
	my $prop_setter = $self->{cntx}->eval(
		'0,function(p,f){__defineSetter__(p, function(v){f(v)})}'
	);
	
	my @props = grep !/^_/ && !($WWW::Scripter::WindowInterface{$_}&METHOD),
		keys %WWW::Scripter::WindowInterface;
	
	foreach my $property (@props) {
		$prop_getter->($property, sub {
			#warn "Prop getter $property";
			$scripter->$property;
		});
		
		unless ($WWW::Scripter::WindowInterface{$property}&READONLY) {
			$prop_setter->($property, sub {
				#warn "Prop setter $property";
				$scripter->$property(@_);
			});
		}
	}
	
	bless $self, $class;
}

sub bind_classes {
	my ($self, $classes) = @_;
	
	for my $module (grep /::/, keys %$classes) {
		my $interface = $classes->{$classes->{$module}};
		
		if ($interface->{_hash} || $interface->{_array}) {
			my %props;
			my %methods;
			my $i = $interface;
			
			do {
				my @methods = grep /^_/ && !($i->{$_}&METHOD),
					keys %$interface;
				
				for my $method (@methods) {
					$pmethods{$method} = undef;
				}
				
				my @props = grep /^_/ && !($i->{$property}&METHOD),
					keys %$interface;
				
				for my $property (@props) {
					$props{$property} = undef;
				}
				
			} while ($i = $classes->{$i->{_isa}});
			
			#$self->[hash]{$_} = [
			#@$i{'_array','_hash'},\%props,\%methods
			#];
		}
		else {
			
		}
}

sub eval {
	#warn "EVAL";
	my ($self, $code, $url, $line) = @_;
	$self->{cntx}->eval($code, $url);
}

1;
