package FridayNight::Model::Schema::Category;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( qw( PK::Auto::MySQL Core ) );
__PACKAGE__->table( 'category' );
__PACKAGE__->add_columns( qw( id status label priority created_date modified_date ) );
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many( 'category_affiliate_map' => 'FridayNight::Model::Schema::CategoryAffiliateMap','category_id' );
__PACKAGE__->many_to_many( 'affiliate' => 'category_affiliate_map', 'affiliate_id' );

1;
