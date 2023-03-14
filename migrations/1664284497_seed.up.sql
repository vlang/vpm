INSERT INTO categories (slug) VALUES ('http'), ('database'), ('logging'), ('gamedev'), ('api'), ('binding'), ('io') ON CONFLICT DO NOTHING;
INSERT INTO users (github_id, username, name, avatar_url) VALUES
    (46413578, 'vlang', 'The V Programming Language', 'https://avatars.githubusercontent.com/u/46413578?v=4'),
    (26527529, 'Terisback', 'Anton Zavodchikov', 'https://avatars.githubusercontent.com/u/26527529?v=4')
ON CONFLICT DO NOTHING;
