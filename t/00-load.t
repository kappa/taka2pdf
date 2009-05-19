#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Taka2PDF' );
}

diag( "Testing App::Taka2PDF $App::Taka2PDF::VERSION, Perl $], $^X" );
