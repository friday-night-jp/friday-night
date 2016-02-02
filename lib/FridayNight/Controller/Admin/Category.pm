package FridayNight::Controller::Admin::Category;

use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use Data::Page::Navigation;
use POSIX 'strftime';
use Data::Dumper;

sub index {
    my $self = shift;

    my $page = $self->param( 'p' ) + 0 || 1;

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );
    my $category = $category_rs->search( {}, 
        { page => $page, rows => $self->config->{ admin_page_rows } } 
    ); 
    $self->stash->{ category } = $category;
    $self->stash->{ pager } = $category->pager(); 

    return $self->render();
}

sub add {
    my $self = shift;

    $self->stash->{ error } = undef;
    $self->stash->{ error_messages } = undef;

    if ( lc $self->req->method eq 'get' ) {
        return $self->render();
    }

    my $validator = $self->_validator( req => $self->req ); 
    if ( $validator->has_error ) {
        my @error_messages;
        for my $message ( $validator->get_error_messages ) {
            push @error_messages, $message;
        }
        $self->stash->{ error } = 1;
        $self->stash->{ error_messages } = \@error_messages;
        return $self->render();
    }

    my $label = $self->param( 'label' );
    my $status = $self->param( 'status' );
    my $priority = $self->param( 'priority' );
    my $current_datetime = strftime( "%Y-%m-%d %H:%M:%S" , localtime );

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );

    my @category = $category_rs->search( { label => $label } );
    if ( @category ) {
        my @error_messages = ( "$label is exists" );
        $self->stash->{ error } = 1;
        $self->stash->{ error_messages } = \@error_messages;
        return $self->render();
    }

    $category_rs->create( {
        label => $label,
        status => $status,
        priority => $priority,
        created_date => $current_datetime,
        modified_date => $current_datetime
    } );

    return $self->redirect_to( '/admin/category' );
}

sub detail {
    my $self = shift;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/category' ) if ! $id;

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );

    my $category = $category_rs->find( $id );
    return $self->redirect_to( '/admin/category' ) if ! $category;
    $self->stash->{ category } = $category;

    return $self->render();
}

sub edit {
    my $self = shift;

    $self->stash->{ error } = undef;
    $self->stash->{ error_messages } = undef;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/category' ) if ! $id;

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );

    my $category = $category_rs->find( $id );
    return $self->redirect_to( '/admin/category' ) if ! $category;
    $self->stash->{ category } = $category;

    if ( lc $self->req->method eq 'get' ) {
        return $self->render();
    }
    elsif ( lc $self->req->method eq 'post' ) {
        my $validator = $self->_validator( req => $self->req ); 
        if ( $validator->has_error ) {
            my @error_messages;
            for my $message ( $validator->get_error_messages ) {
                push @error_messages, $message;
            }
            $self->stash->{ error } = 1;
            $self->stash->{ error_messages } = \@error_messages;
            return $self->render();
        }

        my $label = $self->param( 'label' );
        my $status = $self->param( 'status' );
        my $priority = $self->param( 'priority' );

        my @category = $category_rs->search( {
            id => { '!=' => $id }, label => $label
        } );
        if ( @category ) {
            my @error_messages = ( "$label is exists" );
            $self->stash->{ error } = 1;
            $self->stash->{ error_messages } = \@error_messages;
            return $self->render();
        }

        my $category = $category_rs->find( $id );
        $category->label( $label );
        $category->status( $status );
        $category->priority( $priority );
        $category->modified_date( strftime( "%Y-%m-%d %H:%M:%S" , localtime ) );
        $category->update();
        return $self->redirect_to( "/admin/category" );
    }
}

sub delete {
    my $self = shift;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/category' ) if ! $id;

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );
    my $category = $category_rs->find( $id );
    return $self->redirect_to( '/admin/category' ) if ! $category;

    if ( lc $self->req->method eq 'get' ) {
        $self->stash->{ category } = $category;
        return $self->render();
    }
    elsif ( lc $self->req->method eq 'post' ) {
        $category->delete();
        return $self->redirect_to( '/admin/category' );
    }
}

sub _validator {
    my $self = shift;
    my %p = @_;
    my $req = $p{ req };

    my $validator = FormValidator::Lite->new( $req );
    $validator->set_message(
        'label.not_null'    => 'label is empty.',
        'status.not_null'   => 'status is empty.',
        'status.int'        => 'status is not int.',
        'priority.not_null' => 'priority is empty.',
        'priority.int'      => 'priority is not int.',
    );
    return $validator->check(
        label => [ 'NOT_NULL' ],
        status => [ [ 'NOT_NULL' ], [ 'INT' ] ],
        priority => [ [ 'NOT_NULL' ], [ 'INT' ] ],
    );
}

1;
