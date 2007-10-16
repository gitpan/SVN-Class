use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SVN::Class',
    AUTHOR              => 'Peter Karman <perl@peknet.com>',
    VERSION_FROM        => 'lib/SVN/Class.pm',
    ABSTRACT_FROM       => 'lib/SVN/Class.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Data::Dump' => 0,
        'IPC::Cmd'   => 0,
        'Path::Class' => 0,
        'Path::Class::File::Stat' => 0,
        'Class::Accessor::Fast' => 0,

    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'SVN-Class-*' },
);
