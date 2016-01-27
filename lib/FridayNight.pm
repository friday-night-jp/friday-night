package FridayNight;

use Mojo::Base 'Mojolicious';
use Path::Class;

# This method will run once at server start
sub startup {
    my $self = shift;

    # Documentation browser under "/perldoc"
    $self->plugin( 'PODRenderer' );

    my $home = new Path::Class::File( __FILE__ );
    my $root = $home->dir->resolve->absolute->parent();
    foreach my $e ( 'develop' ) {
        my $f = $root->stringify.'/conf/'.$e.'.conf';
        $self->plugin( 'Config', { 'file' => $f } );
    }

    # Router
    my $r = $self->routes;

    $r->any( '/' )->to( 'root#index' );

    # Admin
    $r->any( [ qw(GET POST) ] => '/admin/login')->to( 'admin-root#login' );
    $r->get( '/admin/logout' )->to( 'admin-root#logout' );
    my $admin_logged_in = $r->under->to( 'admin-root#auth' );
    $admin_logged_in->get( '/admin' )->to( 'admin-root#index' );
}

1;
