use inc::Module::Install;
name 'WWW-TVSchedule-JP';
all_from 'lib/WWW/TVSchedule/JP.pm';

requires 'Cache::FileCache' => 1.06;
requires 'Web::Scraper'     => 0.34;
requires 'URI'              => 1.58;

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
