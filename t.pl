use strict;
use WWW::Scripter;
use lib ('lib', '/tmp/WWW-Scripter-Plugin-JavaScript-0.008a/lib');

my $scripter = WWW::Scripter->new();
$scripter->use_plugin('JavaScript', engine => 'V8');

$scripter->get('http://1000000.gorodok.net/test.html');

print $scripter->document->title, "\n";
