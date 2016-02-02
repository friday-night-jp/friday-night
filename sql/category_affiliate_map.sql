create table category_affiliate_map (
    id INTEGER NOT NULL AUTO_INCREMENT,
    category_id INTEGER NOT NULL,
    affiliate_id INTEGER NOT NULL,
    PRIMARY KEY ( id )
) ENGINE = InnoDB DEFAULT CHARSET=utf8;
