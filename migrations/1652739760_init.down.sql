drop table if exists tokens cascade;

drop table if exists package_tags cascade;

drop table if exists tags cascade;

drop table if exists version_dependencies cascade;

drop table if exists versions cascade;

drop table if exists packages cascade;

drop table if exists users cascade;

drop view if exists most_downloadable_packages cascade;

drop view if exists tags_view cascade;

drop function if exists trigger_update_package_downloaded_at() cascade;

drop function if exists trigger_update_package_updated_at() cascade;

drop function if exists trigger_update_package_downloads() cascade;

drop function if exists trigger_insert_tags_packages() cascade;

drop function if exists trigger_delete_tags_packages() cascade;

drop extension if exists "uuid-ossp";
