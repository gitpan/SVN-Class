use Test::More tests => 26;

BEGIN {
    use_ok('SVN::Class');
}

use IPC::Cmd qw( can_run run );
use File::Temp qw( tempdir );

my $debug = $ENV{PERL_DEBUG} || 1;  # turn on to help debug CPANTS

# create a repos

my $tmpdir = tempdir( CLEANUP => $debug > 1 ? 0 : 1 );
my $repos = Path::Class::Dir->new( $tmpdir, 'svn-class', 'repos' );
my $work  = Path::Class::Dir->new( $tmpdir, 'svn-class', 'work' );


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

    # set up is done. now let's test our SYNOPSIS.

    #  SVN::Class::File
    ok( my $file = svn_file( $work, 'test1' ), "new svn_file" );
    $file->debug(1) if $debug;
    ok( my $fh = $file->open('>>'), "filehandle created" );
    ok( print( {$fh} "hello world\n" ), "hello world" );
    ok( $fh->close,                        "filehandle closed" );
    ok( $file->add,                        "$file scheduled for commit" );
    ok( $file->modified,                   "$file status == modified" );
    ok( $file->commit('the file changed'), "$file committed" );
    ok( my $log = $file->log, "$file has a log" );
    is( $file->outstr, join( "\n", @$log, "" ), "outstr" );

    # SVN::Class::Dir
    ok( my $dir = svn_dir( $work, 'testdir' ), "new svn_dir" );
    $dir->debug(1) if $debug;
    ok( -d $dir ? 1 : $dir->mkpath, "$dir mkpath" );
    ok( $dir->add, "$dir scheduled for commit" );
    is( $dir->status, 'A', "dir status is schedule for Add" );
    ok( $dir->commit('new dir'), "$dir committed" );
    is( $dir->status, 0, "dir status is 0 since it has not changed" );

    # SVN::Class::Info
    ok( my $info = $dir->info, "get info" );
    is( $info->path, $dir, "working path" );

    # SVN::Class::Repos
    is( $info->url, $info->url->info->url, "recursive URL" );
    ok( my $repos = SVN::Class::Repos->new( 'file://' . $repos ),
        "new repos object" );
    my $thisuser = getpwuid($<);
    is( $repos->info->author, $thisuser,
        "$thisuser was last author to commit to $repos" );

}    # end global SKIP
