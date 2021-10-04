drop sequence if exists tokens_user_id_seq;
drop sequence if exists versions_package_id_seq;

drop index if exists users_github_id_uindex;
drop index if exists users_login_uindex;
drop index if exists keywords_slug_uindex;
drop index if exists packages_name_uindex;
drop index if exists packages_repo_url_uindex;
drop index if exists versions_semver_uindex;

drop table if exists version_dependencies;
drop table if exists versions;
drop table if exists package_keywords;
drop table if exists packages;
drop table if exists keywords;
drop table if exists tokens;
drop table if exists users;