ALTER TABLE tags
    RENAME COLUMN package TO packages;

create function trigger_insert_tags_packages()
    returns TRIGGER
    language plpgsql
    as
$$
begin
    update tags
    set packages = packages + 1
    where id = new.tag_id;
    return new;
end;
$$

create trigger insert_tags_packages
	after insert
	on package_tags
	for each row
	execute procedure trigger_insert_tags_packages();

create function trigger_delete_tags_packages()
    returns TRIGGER
    language plpgsql
    as
$$
begin
    update tags
    set packages = packages - 1
    where id = old.tag_id;
end;
$$

create trigger delete_tags_packages
	after delete
	on package_tags
	for each row
	execute procedure trigger_delete_tags_packages();