create function trigger_update_package_downloaded_at()
    returns TRIGGER
    language plpgsql
    as
$$
begin
    if (old.downloads != new.downloads) then
        new.downloaded_at = now();
    end if;
    return new;
end;
$$

create trigger update_package_downloaded_at
	before update
	on packages
	for each row
	execute procedure trigger_update_package_downloaded_at();

create function trigger_update_package_updated_at()
    returns trigger
    language plpgsql
    as
$$
begin
    new.updated_at = now();
    return new;
end;
$$

create trigger update_package_updated_at
	before update
	on packages
	for each row
	execute procedure trigger_update_package_updated_at();

create function trigger_update_package_downloads()
    returns trigger
    language plpgsql
    as
$$
begin
    update packages
    set downloads = downloads + (new.downloads - old.downloads)
    where id = new.package_id;
    return null;
end;
$$

create trigger update_package_updated_at
	after update
	on versions
	for each row
	execute procedure trigger_update_package_downloads();
