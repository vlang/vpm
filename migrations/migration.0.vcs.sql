CREATE TYPE supported_vcs AS ENUM ('git', 'hg');
ALTER TABLE modules ADD COLUMN vcs supported_vcs DEFAULT 'git';
