use inc::Module::Install;

name     'App-Taka2PDF';
all_from 'lib/App/Taka2PDF.pm';

requires    'PDF::API2'     => 0;
requires    'File::Slurp'   => 0;
requires    'Parse::RecDescent' => 0;
requires    'Class::Accessor' => 0;

build_requires 'Test::More';

auto_install;

WriteAll;

