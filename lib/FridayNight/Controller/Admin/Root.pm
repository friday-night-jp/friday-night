package FridayNight::Controller::Admin::Root;

use Mojo::Base 'Mojolicious::Controller';
#use Mojolicious::Sessions;
use CGI::Session;
use Data::Dumper;

sub index {
  my $self = shift;

  $self->render();
}

sub auth {
    my $self = shift;

    if( $self->admin_session->param( 'auth' ) ) {
          return 1;
    }
    else {
        $self->redirect_to( '/admin/login' );
    }
}

sub login {
    my $self = shift;

    if ( $self->param( 'user' ) && $self->param( 'password' ) ) {
        if ( $self->param( 'user' ) eq $self->config->{ 'admin_account' }->{ 'user' } && 
        $self->param( 'password' ) eq $self->config->{ 'admin_account' }->{ 'password' } ) {
            my $session = CGI::Session->new( undef, undef, { Directory => $self->app->home->rel_file( $self->config->{ admin_session_path } ) } );
            $session->param( 'auth', 1 );
            $self->cookie( admin_sessid => $session->id(), { path => '/admin' } );

            $self->redirect_to( '/admin' );
        }
    }
}

sub logout {
    my $self = shift;

    $self->admin_session->delete();
    $self->redirect_to( '/admin' );
}

1;
