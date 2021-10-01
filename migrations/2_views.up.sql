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

create or replace view most_recent_downloads(
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
       packages.downloaded_at DESC;

create or replace view new_packages(
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
       packages.created_at DESC;

create or replace view popular_categories(id, slug, name) as
SELECT
       categories.id,
       categories.slug,
       categories.name
FROM
       categories
       LEFT JOIN package_to_category ptc ON categories.id = ptc.category_id
GROUP BY
       categories.id,
       ptc.category_id
ORDER BY
       (count(ptc.*)) DESC;

create or replace view popular_tags(id, slug, name) as
SELECT
       tags.id,
       tags.slug,
       tags.name
FROM
       tags
       LEFT JOIN package_to_tag ptc ON tags.id = ptc.tag_id
GROUP BY
       tags.id,
       ptc.tag_id
ORDER BY
       (count(ptc.*)) DESC;

create or replace view recently_updated_packages(
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
       packages.updated_at DESC;
