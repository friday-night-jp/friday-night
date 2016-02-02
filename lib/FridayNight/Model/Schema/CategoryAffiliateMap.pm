package FridayNight::Model::Schema::CategoryAffiliateMap;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( qw( PK::Auto::MySQL Core ) );
__PACKAGE__->table( 'category_affiliate_map' );
__PACKAGE__->add_columns( qw( id category_id affiliate_id ) );
__PACKAGE__->set_primary_key( qw( category_id affiliate_id ) );

__PACKAGE__->belongs_to( 'category_id' => 'FridayNight::Model::Schema::Category' );
__PACKAGE__->belongs_to( 'affiliate_id' => 'FridayNight::Model::Schema::Affiliate' );

1;
