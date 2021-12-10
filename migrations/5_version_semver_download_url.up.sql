ALTER TABLE versions
    RENAME COLUMN tag TO semver;

ALTER TABLE versions
    RENAME COLUMN release_url TO download_url;

ALTER TABLE versions
    DROP COLUMN commit_hash;

