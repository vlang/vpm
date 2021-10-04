create or replace function trigger_update_package_downloaded_at()
    returns TRIGGER
    language plpgsql
    as
$$
begin
    update packages
    set downloaded_at = now()
    where id = new.id
    and old.downloads != new.downloads;
end;
$$

create trigger update_package_downloaded_at
	after update
	on packages
	for each row
	execute procedure trigger_update_package_downloaded_at();

create or replace function trigger_update_package_updated_at()
    returns trigger
    language plpgsql
    as
$$
begin
    update packages
    set updated_at = now()
    where id = new.id;
end;
$$

create trigger update_package_updated_at
	after update
	on packages
	for each row
	execute procedure trigger_update_package_updated_at();

create or replace function trigger_update_package_downloads()
    returns trigger
    language plpgsql
    as
$$
begin
    update packages
    set downloads = downloads + (new.downloads - old.downloads)
    where id = new.package_id;
end;
$$

create trigger update_package_updated_at
	after update
	on versions
	for each row
	execute procedure trigger_update_package_downloads();