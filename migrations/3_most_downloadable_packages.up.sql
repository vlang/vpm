create or replace view most_downloadable_packages(
       id,
       author_id,
       name,
       description,
       license,
       repo_url,
       stars,
       downloads,
       downloaded_at,
       created_at,
       updated_at
) as
SELECT
       packages.id,
       packages.author_id,
       packages.name,
       packages.description,
       packages.license,
       packages.repo_url,
       packages.stars,
       packages.downloads,
       packages.downloaded_at,
       packages.created_at,
       packages.updated_at
FROM
       packages
ORDER BY
       packages.downloads DESC;