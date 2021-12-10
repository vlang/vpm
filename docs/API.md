# At least some documentation of the api

<!-- Someone at some time should write more helpful doc... -->

## Endpoints

### Package Endpoints

> __`:name`__ is package name like `/api/package/vsl`, but you could also provide id of package `/api/package/104`, naming conventions of packages is the same as variables.

- **GET** `/api/package/search?q=log&limit=6&offset=0` - Returns json **array** of [package struct](#Package-Struct) or 500.  
**Limitations:**  
  - `q` - query is limited by 255 characters
  - 0 < `limit` < 100, default is 6
- **GET** `/api/package/:name` - Returns json of [package struct](#Package-Struct) or 404.
- **GET** `/api/package/:name/versions` - Returns json **array** of [version struct](#Version-Struct) or 404.
<!-- - **POST** `/api/package?repo=...` - Returns json of [package struct](#Package-Struct) on success or 401, 404. -->

### Tag Endpoints

> __`:name`__ is tag name like `/api/tag/cli`, but you could also provide id `/api/tag/4`.

- **GET** `/api/tag` - Returns json **array** of [tag struct](#Tag-Struct) or 500.
- **GET** `/api/tag/:name?limit=6&offset=0` - Returns json **array** of [package struct](#Package-Struct) or 404.

### User Endpoints

> __`:name`__ is username like `/api/user/terisback`, but you could also provide id `/api/user/1`.

- **GET** `/api/user/:name` - Returns user packages in json **array** of [package struct](#Package-Struct) or 404.

## Structs

### Package Struct

```v
struct Package {
    id         int
    author_id  int
    gh_repo_id int

    name          string
    description   string
    documentation string

    // git repo url
    repository    string

    stars         int
    downloads     int
    downloaded_at time.Time

    created_at time.Time
    updated_at time.Time
}
```

### Tag Struct

```v
struct Tags {
    id       int
    slug     string
    name     string
    packages ints
}
```

### User Struct

```v
struct User {
    id        int
    gh_id     int
    gh_login  string
    gh_avatar string
    name      string

    is_blocked   bool
    block_reason string
}
```

### Version Struct

```v
struct Version {
    id         int
    package_id int

    semver    string
    downloads int
    download_url string
    release_date time.Time
}
```
