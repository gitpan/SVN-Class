use Test::More tests => 20;

BEGIN {
    use_ok('SVN::Class');
}

use IPC::Cmd qw( can_run run );

my $debug = $ENV{PERL_DEBUG} || 1;   # 0.05 turned this on to help debug CPANTS

# create a repos

my $tmpdir = $ENV{TMPDIR} || '/tmp';
my $repos = Path::Class::Dir->new( $tmpdir, 'svn-class', 'repos' );
my $work  = Path::Class::Dir->new( $tmpdir, 'svn-class', 'work' );

END {
    unless ($debug > 1) {
        $repos->rmtree;
        $work->rmtree;
    }
}

# if we don't have svn in PATH can't do much.
SKIP: {
    skip "svn is not in PATH", 19 unless can_run('svn');

    # if running multiple times, test for existence of our repos & work dirs

SKIP: {

        if ( -d $repos && -s "$repos/format" ) {
            skip "repos setup already complete", 5;
        }

        ok( $repos->mkpath, "repos path made" );
        ok( $work->mkpath,  "work path made" );
        ok( run( command => "svnadmin create $repos" ),
            "repos $repos created" );

        # create a project in repos and check it out in $work
        ok( run( command => "svn mkdir file://$repos/test -m init" ),
            "test project created in repos" );

        ok( run( command => "cd $work && svn co file://$repos/test ." ),
            "test checked out" );

    }

    #diag("setup done");

    # set up is done. now let's test our SYNOPSIS.

    ok( my $file = svn_file( $work, 'test1' ), "new svn_file" );

    #diag("svn_file done");

    $file->debug(1) if $debug;
    ok( my $fh = $file->open('>>'), "filehandle created" );
    ok( print( {$fh} "hello world\n" ), "hello world" );
    ok( $fh->close,                        "filehandle closed" );
    ok( $file->add,                        "$file scheduled for commit" );
    ok( $file->modified,                   "$file status == modified" );
    ok( $file->commit('the file changed'), "$file committed" );
    ok( my $log = $file->log, "$file has a log" );

    #diag( join( "\n", @$log ) );

    #diag("$file tests done");

    ok( my $dir = svn_dir( $work, 'testdir' ), "new svn_dir" );
    $dir->debug(1) if $debug;
    ok( -d $dir ? 1 : $dir->mkpath, "$dir mkpath" );
    ok( $dir->add, "$dir scheduled for commit" );
    is( $dir->status, 'A', "dir status is schedule for Add" );
    ok( $dir->commit('new dir'), "$dir committed" );
    is( $dir->status, 0, "dir status is 0 since it has not changed" );

    #diag("$dir tests done");

}    # end global SKIP
