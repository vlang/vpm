ALTER TABLE versions
    RENAME COLUMN semver TO tag;

ALTER TABLE versions
    RENAME COLUMN download_url TO release_url;

ALTER TABLE versions
    ADD COLUMN commit_hash varchar(40);
