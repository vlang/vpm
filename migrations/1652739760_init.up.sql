create extension if not exists "uuid-ossp";

create sequence versions_package_id_seq
    as integer;

create table users
(
    id           serial
        constraint users_pk
            primary key,
    gh_id        integer               not null,
    login        varchar(39)           not null,
    avatar       text,
    name         varchar(255)          not null,
    access_token varchar(40)           not null,
    is_blocked   boolean default false not null,
    block_reason text,
    is_admin     boolean default false not null
);

create unique index users_gh_id_uindex
    on users (gh_id);

create unique index users_gh_login_uindex
    on users (login);

create table tokens
(
    id           serial
        constraint tokens_pk
            primary key,
    user_id      integer                                not null
        constraint tokens_users_id_fk
            references users
            on update cascade on delete cascade,
    token        varchar(64)                            not null,
    revoked      boolean,
    created_at   timestamp with time zone default now() not null,
    last_used_at timestamp with time zone default now() not null
);

create table tags
(
    id       serial
        constraint tags_pk
            primary key,
    slug     text              not null,
    packages integer default 0 not null
);

create unique index tags_slug_uindex
    on tags (slug);

create table packages
(
    id            serial
        constraint packages_pk
            primary key,
    author_id     integer                                not null
        constraint packages_users_id_fk
            references users
            on update cascade on delete restrict,
    name          varchar(100)                           not null,
    description   varchar(140),
    documentation text,
    repository    text                                   not null,
    stars         integer                  default 0     not null,
    downloads     integer                  default 0     not null,
    downloaded_at timestamp with time zone default now() not null,
    created_at    timestamp with time zone default now() not null,
    updated_at    timestamp with time zone default now() not null,
    gh_repo_id    integer
);

create unique index packages_repository_uindex
    on packages (repository);

create unique index packages_name_uindex
    on packages (name);

create table package_tags
(
    package_id integer not null
        constraint package_tags_packages_id_fk
            references packages
            on update cascade on delete cascade,
    tag_id     integer not null
        constraint package_tags_tags_id_fk
            references tags
            on update cascade on delete cascade
);

create table versions
(
    id           serial
        constraint versions_pk
            primary key,
    package_id   integer                  not null
        constraint versions_packages_id_fk
            references packages,
    semver       varchar(255)             not null,
    downloads    integer default 0        not null,
    download_url text,
    release_date timestamp with time zone not null
);

alter sequence versions_package_id_seq owned by versions.package_id;

create unique index versions_semver_uindex
    on versions (semver);

create table version_dependencies
(
    version_id    integer
        constraint version_dependencies_versions_id_fk
            references versions
            on update cascade on delete cascade,
    dependency_id integer
        constraint version_dependencies_versions_id_fk_2
            references versions
            on update cascade on delete restrict,
    constraint version_dependencies_check
        check (version_id <> dependency_id)
);

create view most_downloadable_packages
            (id, author_id, gh_repo_id, name, description, documentation, repository, stars, downloads, downloaded_at,
             created_at, updated_at)
as
SELECT packages.id,
       packages.author_id,
       packages.gh_repo_id,
       packages.name,
       packages.description,
       packages.documentation,
       packages.repository,
       packages.stars,
       packages.downloads,
       packages.downloaded_at,
       packages.created_at,
       packages.updated_at
FROM packages
ORDER BY packages.downloads DESC;

create view tags_view(id, slug, packages) as
SELECT tags.id,
       tags.slug,
       tags.packages
FROM tags
ORDER BY tags.packages DESC;

create function trigger_update_package_downloaded_at() returns trigger
    language plpgsql
as
$$
begin
    if (old.downloads != new.downloads) then
        new.downloaded_at = now();
    end if;
    return new;
end;
$$;

create trigger update_package_downloaded_at
    before update
    on packages
    for each row
execute procedure trigger_update_package_downloaded_at();

create function trigger_update_package_updated_at() returns trigger
    language plpgsql
as
$$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger update_package_updated_at
    before update
    on packages
    for each row
execute procedure trigger_update_package_updated_at();

create function trigger_update_package_downloads() returns trigger
    language plpgsql
as
$$
begin
    update packages
    set downloads = downloads + (new.downloads - old.downloads)
    where id = new.package_id;
    return null;
end;
$$;

create trigger update_package_updated_at
    after update
    on versions
    for each row
execute procedure trigger_update_package_downloads();

create function trigger_insert_tags_packages() returns trigger
    language plpgsql
as
$$
begin
    update tags
    set packages = packages + 1
    where id = new.tag_id;
    return new;
end;
$$;

create trigger insert_tags_packages
    after insert
    on package_tags
    for each row
execute procedure trigger_insert_tags_packages();

create function trigger_delete_tags_packages() returns trigger
    language plpgsql
as
$$
begin
    update tags
    set packages = packages - 1
    where id = old.tag_id;
end;
$$;

create trigger delete_tags_packages
    after delete
    on package_tags
    for each row
execute procedure trigger_delete_tags_packages();
