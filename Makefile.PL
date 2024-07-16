use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Extender',
    VERSION_FROM => 'lib/Extender.pm',  # Path to your main module file
    AUTHOR       => 'OnEhIppY @ Domero Software <domerosoftware@gmail.com>',
    ABSTRACT     => 'Dynamically extend an object with methods from another module',
    LICENSE      => 'perl',  # License type
    PREREQ_PM    => {},     # Additional dependencies, if any
    EXE_FILES    => ['example/Extender.pl'],  # List of executable scripts
    META_MERGE   => {
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/DomeroSoftware/Extender.git',
                web  => 'https://github.com/DomeroSoftware/Extender',
            },
        },
    },
);
