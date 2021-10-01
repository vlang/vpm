-- create schema if not exists vpm authorization postgres;

create table if not exists users (
	id serial 
		constraint users_pk primary key,
	github_id integer not null,
	login varchar(39) not null,
	name varchar(255) not null,
	avatar_url text,
	is_blocked boolean default false not null,
	is_admin boolean default false not null
);

create table if not exists access_tokens (
	user_id integer not null 
		constraint access_tokens_users_id_fk references users 
			on update cascade on delete cascade,
	value uuid default uuid_generate_v4() not null,
	ip integer,
	created_at timestamptz default now() not null
);

create table if not exists gh_tokens (
	user_id integer not null 
		constraint gh_tokens_users_id_fk references users 
			on update cascade on delete cascade,
	token varchar(255) not null
);

create table if not exists categories (
	id serial 
		constraint categories_pk primary key,
	slug text not null,
	name text not null
);

create table if not exists tags (
	id serial 
		constraint tags_pk primary key,
	slug text not null,
	name text not null
);

create table if not exists packages (
	id serial 
		constraint packages_pk primary key,
	author_id integer not null 
		constraint packages_users_id_fk references users 
			on update cascade on delete restrict,
	name varchar(64) not null,
	description varchar(140),
	license varchar(64),
	repo_url varchar(256) not null,
	stars integer default 0 not null,
	downloads integer default 0 not null,
	downloaded_at timestamptz default now() not null,
	created_at timestamptz default now() not null,
	updated_at timestamptz default now() not null
);

create table if not exists package_to_tag (
	package_id integer not null 
		constraint package_to_tag_packages_id_fk references packages 
			on update cascade on delete cascade,
	tag_id integer not null 
		constraint package_to_tag_tags_id_fk references tags 
			on update cascade on delete cascade
);

create table if not exists package_to_category (
	package_id integer not null 
		constraint package_to_category_packages_id_fk references packages 
			on update cascade on delete cascade,
	category_id integer not null 
		constraint package_to_category_categories_id_fk references categories 
			on update cascade on delete cascade
);

create table if not exists versions (
	id serial 
		constraint versions_pk primary key,
	package_id integer not null 
		constraint versions_packages_id_fk references packages,
	tag varchar(255) not null,
	-- Only semver tags will be used by vpm
	downloads integer default 0 not null,
	commit_hash varchar(40) not null,
	-- Git hash length is 40 digits
	release_url text,
	release_date timestamptz not null
);

create table dependencies (
	version_id integer 
		constraint dependencies_versions_id_fk references versions 
			on update cascade on delete cascade,
	dependency_id integer 
		constraint dependencies_versions_id_fk_2 references versions 
			on update cascade on delete restrict,
	constraint dependencies_check check (version_id <> dependency_id)
);

create unique index if not exists users_github_id_uindex on users (github_id);

create unique index if not exists users_login_uindex on users (login);

create unique index if not exists categories_name_uindex on categories (name);

create unique index if not exists categories_slug_uindex on categories (slug);

create unique index if not exists tags_name_uindex on tags (name);

create unique index if not exists tags_slug_uindex on tags (slug);

create unique index if not exists packages_name_uindex on packages (name);

create unique index if not exists packages_repo_url_uindex on packages (repo_url);

create unique index if not exists versions_semver_uindex on versions (tag);

create sequence tokens_user_id_seq as integer;

alter sequence tokens_user_id_seq owned by access_tokens.user_id;

create sequence versions_package_id_seq as integer;

alter sequence versions_package_id_seq owned by versions.package_id;