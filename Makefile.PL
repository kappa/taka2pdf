use inc::Module::Install;

name     'App-Taka2PDF';
all_from 'lib/App/Taka2PDF.pm';
author   'Alex Kapranoff <alex@kapranoff.ru>';

build_requires 'Test::More';

auto_install;

WriteAll;

