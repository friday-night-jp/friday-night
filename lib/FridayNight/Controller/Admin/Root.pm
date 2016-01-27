package FridayNight::Controller::Admin::Root;

use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

  $self->render();
}

sub auth {
    my $self = shift;

    if( $self->session->{ auth } ) {
          return 1;
    }
    else {
        $self->redirect_to( '/admin/login' );
    }
}

sub login {
    my $self = shift;

    if ( $self->param( 'user' ) && $self->param( 'password' ) ) {
        $self->app->log->info( "pass check" );
        if ( $self->param( 'user' ) eq $self->config->{ 'admin_account' }->{ 'user' } && 
        $self->param( 'password' ) eq $self->config->{ 'admin_account' }->{ 'password' } ) {
            $self->session->{ auth } = 1;
            $self->redirect_to( '/admin' );
        }
    }
}

sub logout {
    my $self = shift;

    $self->session->{ auth } = undef;
    $self->redirect_to( '/admin' );
}

1;
