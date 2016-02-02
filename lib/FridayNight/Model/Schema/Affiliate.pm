package FridayNight::Model::Schema::Affiliate;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( qw( PK::Auto::MySQL Core ) );
__PACKAGE__->table( 'affiliate' );
__PACKAGE__->add_columns( qw( id status site_name priority created_date modified_date ) );
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many( 'category_affiliate_map' => 'FridayNight::Model::Schema::CategoryAffiliateMap','affiliate_id' );
__PACKAGE__->many_to_many( 'category' => 'category_affiliate_map', 'category_id' );

1;
