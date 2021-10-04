delete trigger if exists update_package_updated_at on versions;
drop function if exists trigger_update_package_downloads();
delete trigger if exists update_package_updated_at on packages;
drop function if exists trigger_update_package_updated_at();
delete trigger if exists update_package_downloaded_at on packages;
drop function if exists trigger_update_package_downloaded_at();




