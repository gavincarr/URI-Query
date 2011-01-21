use 5.00503;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'URI::Query',
    'VERSION_FROM'	=> 'Query.pm', # finds $VERSION
    'PREREQ_PM'		=> {
       URI          => 1.31,
       Test::More   => 0.88,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (AUTHOR     => 'Gavin Carr <gavin@openfusion.com.au>') : ()),
);
