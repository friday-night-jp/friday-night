package FridayNight;

use Mojo::Base 'Mojolicious';
use FridayNight::Model::Schema;
use Path::Class;
use CGI::Session;
use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin( 'PODRenderer' );

    # Config
    foreach my $e ( 'env', 'main' ) {
        my $f = $self->app->home->rel_file( 'conf/' . $e . '.conf' );
        $self->plugin( 'Config', { 'file' => $f } );
    }

    # MySQL
    my $mysql = $self->config->{ mysql };
    $self->helper(
        'schema' => sub { 
            FridayNight::Model::Schema->connect(
                "dbi:mysql:$mysql->{ database }",
                $mysql->{ user },
                $mysql->{ password },
                { mysql_enable_utf8 => 1 }
            )
        }
    );

    # Session
    $self->helper(
        'admin_session' => sub { 
            my $self = shift;
            my $admin_sessid = $self->cookie( 'admin_sessid' );
            return CGI::Session->load( undef, $admin_sessid, { Directory => $self->param( 'root_path' ) . $self->config->{ admin_session_path } } );
        }
    );

    my $r = $self->routes;

    $r->any( '/' )->to( 'root#index' );

    # Admin
    $r->any( [ qw(GET POST) ] => '/admin/login')->to( 'admin-root#login' );
    $r->get( '/admin/logout' )->to( 'admin-root#logout' );

    my $admin_logged_in = $r->under->to( 'admin-root#auth' );
    $admin_logged_in->get( '/admin' )->to( 'admin-root#index' );

    $admin_logged_in->get( '/admin/category' )->to( 'admin-category#index' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/category/add' )->to( 'admin-category#add' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/category/edit/:id' )->to( 'admin-category#edit' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/category/delete/:id' )->to( 'admin-category#delete' );
    $admin_logged_in->get( '/admin/category/detail/:id' )->to( 'admin-category#detail' );

    $admin_logged_in->get( '/admin/affiliate' )->to( 'admin-affiliate#index' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/affiliate/add' )->to( 'admin-affiliate#add' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/affiliate/edit/:id' )->to( 'admin-affiliate#edit' );
    $admin_logged_in->any( [ qw( GET POST ) ] => '/admin/affiliate/delete/:id' )->to( 'admin-affiliate#delete' );
    $admin_logged_in->get( '/admin/affiliate/detail/:id' )->to( 'admin-affiliate#detail' );
}

1;
