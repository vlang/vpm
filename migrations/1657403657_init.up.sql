create sequence category_id_seq
    as integer;

create table users
(
    id           serial
        constraint users_pk
            primary key,
    github_id    integer                 not null,
    username     text                    not null,
    name         text,
    avatar_url   text,
    is_blocked   boolean   default false not null,
    block_reason text,
    is_admin     boolean   default false,
    created_at   timestamp default now() not null,
    updated_at   timestamp default now() not null
);

create unique index users_github_id_uindex
    on users (github_id);

create unique index users_username_uindex
    on users (username);

create table auths
(
    id         serial
        constraint auths_pk
            primary key,
    user_id    integer
        constraint auths_users_id_fk
            references users
            on update cascade on delete cascade,
    kind       text      default 'github_oauth'::text not null,
    value      text                                   not null,
    created_at timestamp default now()                not null,
    updated_at timestamp default now()                not null
);

create table categories
(
    id         serial
        constraint categories_pk
            primary key,
    slug       text                    not null,
    packages   integer   default 0,
    created_at timestamp default now() not null,
    updated_at timestamp default now() not null
);

alter sequence category_id_seq owned by categories.id;

create unique index category_slug_uindex
    on categories (slug);

create table categories_packages
(
    category_id integer not null
        constraint categories_packages_categories_id_fk
            references categories
            on update cascade on delete cascade,
    package_id integer not null
        constraint categories_packages_packages_id_fk
            references packages
            on update cascade on delete cascade
);

create table packages
(
    id            serial
        constraint packages_pk
            primary key,
    author_id     integer
        constraint packages_users_id_fk
            references users
            on update cascade on delete set null,
    github_id     integer                       not null,
    name          text                          not null,
    description   text,
    repository    text                          not null,
    documentation text,
    license       text                          not null,
    vcs           text      default 'git'::text not null,
    url           text                          not null,
    stars         integer   default 0           not null,
    downloads     integer   default 0           not null,
    downloaded_at timestamp default now()       not null,
    is_hidden     boolean   default false       not null,
    is_flatten    boolean   default false       not null,
    created_at    timestamp default now()       not null,
    updated_at    timestamp default now()       not null
);

create unique index packages_github_id_uindex
    on packages (github_id);

create unique index packages_name_uindex
    on packages (name);
