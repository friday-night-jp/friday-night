package FridayNight::Controller::Admin::Affiliate;

use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use Data::Page::Navigation;
use POSIX 'strftime';
use Data::Dumper;

sub index {
    my $self = shift;

    my $page = $self->param( 'p' ) + 0 || 1;

    my $schema = $self->schema;
    my $affiliate_rs = $schema->resultset( 'Affiliate' );
    my $affiliate = $affiliate_rs->search( {},
        { page => $page, rows => $self->config->{ admin_page_rows } }
    );    
    $self->stash->{ affiliate } = $affiliate;
    $self->stash->{ pager } = $affiliate->pager(); 

    return $self->render();
}

sub add {
    my $self = shift;

    $self->stash->{ error } = undef;
    $self->stash->{ error_messages } = undef;

    my $schema = $self->schema;
    my $category_rs = $schema->resultset( 'Category' );
    my @category = $category_rs->search( 
        { status => $self->config->{ status }->{ active } } 
    );
    $self->stash->{ 'category' } = \@category;

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

        my $site_name = $self->param( 'site_name' );
        my $status = $self->param( 'status' );
        my $priority = $self->param( 'priority' );
        my $category = $self->every_param( 'category' );
        my $current_datetime = strftime( "%Y-%m-%d %H:%M:%S" , localtime );

        my $affiliate_rs = $schema->resultset( 'Affiliate' );

        my @affliate = $affiliate_rs->search( { site_name => $site_name} );
        if ( @affliate ) {
            my @error_messages = ( "$site_name is exists" );
            $self->stash->{ error } = 1;
            $self->stash->{ error_messages } = \@error_messages;
            return $self->render();
        }

        my $affili_res = $affiliate_rs->create( {
            site_name => $site_name,
            status => $status,
            priority => $priority,
            created_date => $current_datetime,
            modified_date => $current_datetime
        } );
        my $cate_affili_map = $schema->resultset( 'CategoryAffiliateMap' );
        foreach my $cate ( @{ $category } ) {
            $cate_affili_map->create( { 
                category_id => $cate, affiliate_id => $affili_res->id 
            } );
        }

        return $self->redirect_to( '/admin/affiliate' );
    }

    return $self->redirect_to( '/admin/category' );
}

sub detail {
    my $self = shift;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/affiliate' ) if ! $id;

    my $schema = $self->schema;
    my $affiliate_rs = $schema->resultset( 'Affiliate' );

    my $affiliate = $affiliate_rs->find( $id );
    return $self->redirect_to( '/admin/affiliate' ) if ! $affiliate;
    $self->stash->{ affiliate } = $affiliate;

    return $self->render();
}

sub edit {
    my $self = shift;

    $self->stash->{ error } = undef;
    $self->stash->{ error_messages } = undef;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/affiliate' ) if ! $id;

    my $schema = $self->schema;

    my $category_rs = $schema->resultset( 'Category' );
    my @category = $category_rs->search( { status => $self->config->{ status }->{ active } } );
    $self->stash->{ category } = \@category;

    my $affiliate_rs = $schema->resultset( 'Affiliate' );
    my $affiliate = $affiliate_rs->find( $id );
    return $self->redirect_to( '/admin/affiliate' ) if ! $affiliate;
    $self->stash->{ affiliate } = $affiliate;

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

        my $site_name = $self->param( 'site_name' );
        my $status = $self->param( 'status' );
        my $priority = $self->param( 'priority' );
        my $category = $self->every_param( 'category' );

        my @affiliate = $affiliate_rs->search( {
            id => { '!=' => $id }, site_name => $site_name
        } );
        if ( @affiliate ) {
            my @error_messages = ( "$site_name is exists" );
            $self->stash->{ error } = 1;
            $self->stash->{ error_messages } = \@error_messages;
            return $self->render();
        }

        my $affiliate = $affiliate_rs->find( $id );
        $affiliate->site_name( $site_name );
        $affiliate->status( $status );
        $affiliate->priority( $priority );
        $affiliate->modified_date( strftime( "%Y-%m-%d %H:%M:%S" , localtime ) );
        $affiliate->update();

        my $cate_affili_map_rs = $schema->resultset( 'CategoryAffiliateMap' );
        $cate_affili_map_rs->search( { affiliate_id => $id } )->delete();
        foreach my $cate ( @{ $category } ) {
            $cate_affili_map_rs->create( { 
                category_id => $cate, affiliate_id => $id 
            } );
        }

        return $self->redirect_to( '/admin/affiliate' );
    }
}

sub delete {
    my $self = shift;

    my $id = $self->param( 'id' ) + 0; 
    return $self->redirect_to( '/admin/affiliate' ) if ! $id;

    my $schema = $self->schema;
    my $affiliate_rs = $schema->resultset( 'Affiliate' );
    my $affiliate = $affiliate_rs->find( $id );
    return $self->redirect_to( '/admin/affiliate' ) if ! $affiliate;

    if ( lc $self->req->method eq 'get' ) {
        $self->stash->{ affiliate } = $affiliate;
        return $self->render();
    }
    elsif ( lc $self->req->method eq 'post' ) {
        $affiliate->delete();

        my $cate_affili_map_rs = $schema->resultset( 'CategoryAffiliateMap' );
        $cate_affili_map_rs->search( { affiliate_id => $id } )->delete();

        return $self->redirect_to( '/admin/affiliate' );
    }
}

sub _validator {
    my $self = shift;
    my %p = @_;
    my $req = $p{ req };

    my $validator = FormValidator::Lite->new( $req );
    $validator->set_message(
        'site_name.not_null'=> 'site_name is empty.',
        'status.not_null'   => 'status is empty.',
        'status.int'        => 'status is not int.',
        'priority.not_null' => 'priority is empty.',
        'priority.int'      => 'priority is not int.',
        'category.not_null' => 'category is empty.',
    );
    return $validator->check(
        site_name => [ 'NOT_NULL' ],
        status => [ [ 'NOT_NULL' ], [ 'INT' ] ],
        priority => [ [ 'NOT_NULL' ], [ 'INT' ] ],
        category => [ 'NOT_NULL' ],
    );
}

1;
