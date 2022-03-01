create view tags_view(
       id,
       slug,
       packages
) as
SELECT
       tags.id,
       tags.slug,
       tags.packages
FROM
       tags
ORDER BY
       tags.packages DESC;
