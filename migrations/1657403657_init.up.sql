create table users
(
    username     text                    not null
        constraint users_pk
            primary key
        constraint users_username_check
            check (char_length(username) <= 39),
    name         text                    not null,
    avatar_url   text,
    is_blocked   boolean   default false not null,
    block_reason text,
    is_admin     boolean   default false not null,
    created_at   timestamp default now() not null,
    updated_at   timestamp default now() not null
);

create unique index users_username_uindex
    on users (username);

create table auths
(
    username   text                                   not null
        constraint auths_users_id_fk
            references users
            on update cascade on delete cascade,
    kind       text      default 'github_oauth'::text not null,
    value      text                                   not null,
    created_at timestamp default now()                not null,
    updated_at timestamp default now()                not null,
    constraint auths_pk
        primary key (username, kind)
);

create table packages
(
    id            serial
        constraint packages_pk
            primary key,
    author        text                          not null
        constraint packages_users_id_fk
            references users
            on update cascade on delete restrict,
    name          text                          not null
        constraint packages_name_check
            check (char_length(name) <= 100),
    description   text      default ''::text    not null,
    documentation text      default ''::text    not null,
    repository    text                          not null,
    license       text                          not null,
    vcs           text      default 'git'::text not null,
    url           text                          not null,
    stars         integer   default 0           not null,
    downloads     integer   default 0           not null,
    downloaded_at timestamp default now()       not null,
    is_hidden     boolean   default false       not null,
    is_flatten    boolean   default false       not null,
    created_at    timestamp default now()       not null,
    updated_at    timestamp default now()       not null,
    constraint packages_author_name_unique
        unique (author, name)
);

create table categories
(
    id         serial
        constraint categories_pk
            primary key,
    slug       text                    not null,
    packages   integer   default 0     not null,
    created_at timestamp default now() not null,
    updated_at timestamp default now() not null
);

create unique index categories_slug_uindex
    on categories (slug);

create table categories_packages
(
    category_id integer not null
        constraint categories_packages_categories_id_fk
            references categories
            on update cascade on delete cascade,
    package_id  integer not null
        constraint categories_packages_packages_id_fk
            references packages
            on update cascade on delete cascade,
    constraint categories_packages_pk
        primary key (category_id, package_id)
);

create table tags
(
    id            serial
        constraint tags_pk
            primary key,
    package_id    integer                 not null
        constraint tags_packages_id_fk
            references packages
            on update cascade on delete cascade,
    name          text                    not null,
    downloads     integer   default 0     not null,
    downloaded_at timestamp default now() not null,
    created_at    timestamp default now() not null,
    updated_at    timestamp default now() not null
);
