package FridayNight::Model::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes( qw( Category Affiliate CategoryAffiliateMap ) );

1;
