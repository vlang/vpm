create table users (
	id serial
		constraint users_pk primary key,
	gh_id integer not null,
	gh_login varchar(39) not null,
	gh_avatar text,
	name varchar(255) not null,
	access_token varchar(40) not null,
	is_blocked boolean default false not null,
	block_reason text,
	is_admin boolean default false not null
);

create table tokens (
	id serial
		constraint tokens_pk primary key,
	user_id integer not null
		constraint tokens_users_id_fk references users
			on update cascade on delete cascade,
	token varchar(64) not null,
	revoked boolean,
	created_at timestamptz default now() not null,
	last_used_at timestamptz default now() not null
);

create table tags (
	id serial
		constraint tags_pk primary key,
	slug text not null,
	name text not null,
	package integer default 0 not null
);

create table packages (
	id serial
		constraint packages_pk primary key,
	author_id integer not null
		constraint packages_users_id_fk references users
			on update cascade on delete restrict,

	name varchar(64) not null,
	description varchar(140),
	documentation text,
	repository text not null,

	stars integer default 0 not null,
	downloads integer default 0 not null,
	downloaded_at timestamptz default now() not null,

	created_at timestamptz default now() not null,
	updated_at timestamptz default now() not null
);

create table package_tags (
	package_id integer not null
		constraint package_tags_packages_id_fk references packages
			on update cascade on delete cascade,
	tag_id integer not null
		constraint package_tags_tags_id_fk references tags
			on update cascade on delete cascade
);

create table versions (
	id serial
		constraint versions_pk primary key,
	package_id integer not null
		constraint versions_packages_id_fk references packages,
	-- Only semver tags will be used by vpm
	tag varchar(255) not null,
	downloads integer default 0 not null,
	-- Git hash length is 40 digits
	commit_hash varchar(40) not null,
	release_url text,
	release_date timestamptz not null
);

create table version_dependencies (
	version_id integer
		constraint version_dependencies_versions_id_fk references versions
			on update cascade on delete cascade,
	dependency_id integer
		constraint version_dependencies_versions_id_fk_2 references versions
			on update cascade on delete restrict,
	constraint version_dependencies_check check (version_id <> dependency_id)
);

create unique index users_gh_id_uindex on users (gh_id);

create unique index users_gh_login_uindex on users (gh_login);

create unique index tags_slug_uindex on tags (slug);

create unique index packages_name_uindex on packages (name);

create unique index packages_repository_uindex on packages (repository);

create unique index versions_semver_uindex on versions (tag);

create sequence versions_package_id_seq as integer;

alter sequence versions_package_id_seq owned by versions.package_id;
