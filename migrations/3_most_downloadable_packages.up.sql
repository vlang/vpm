create view most_downloadable_packages(
       id,
       author_id,
       name,
       description,
       documentation,
       repository,
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
       packages.documentation,
       packages.repository,
       packages.stars,
       packages.downloads,
       packages.downloaded_at,
       packages.created_at,
       packages.updated_at
FROM
       packages
ORDER BY
       packages.downloads DESC;
