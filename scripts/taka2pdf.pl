#! /usr/bin/perl
use strict;
use warnings;

use App::Taka2PDF;

use Carp qw/cluck/;

$SIG{__DIE__} = \&Carp::confess;

App::Taka2PDF::run();
