create table affiliate (
    id INTEGER NOT NULL AUTO_INCREMENT,
    status INTEGER NOT NULL,
    site_name varchar( 256 ) NOT NULL,
    priority INTEGER NOT NULL,
    created_date DATETIME NOT NULL,
    modified_date DATETIME NOT NULL,
    PRIMARY KEY ( id )
) ENGINE = InnoDB DEFAULT CHARSET=utf8;
