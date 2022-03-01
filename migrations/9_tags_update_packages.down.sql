ALTER TABLE tags
    RENAME COLUMN packages TO package;

drop trigger if exists insert_tags_packages on package_tags;
drop function if exists trigger_insert_tags_packages();
drop trigger if exists delete_tags_packages on package_tags;
drop function if exists trigger_delete_tags_packages();
