CREATE TYPE supported_vcs AS ENUM ('git', 'hg');
CREATE TABLE modules ( 
    id serial primary key,  
    user_id int default 0, 
    name text default '', 
    url text default '', 
    vcs supported_vcs DEFAULT 'git'
);
