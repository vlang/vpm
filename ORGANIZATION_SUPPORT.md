# VPM Organization Support Feature

## Problem

Currently, VPM only allowed users to publish packages from repositories under their own GitHub account. The validation in `check_vcs()` required the repository URL to start with `https://github.com/{username}/`, where `username` is the logged-in user's GitHub username.

This prevented users from publishing packages from GitHub organizations they belong to.

## Solution Overview

1. Add database tables to store a user's GitHub organization memberships and OAuth token
2. Fetch user's organizations during OAuth login, refreshing on every login
3. `check_vcs_with_orgs()` accepts organization URLs where the user is a member, or admin bypass
4. Automatically use organization name as package prefix when publishing from org repos
5. Before letting a create/update go through under an organization's namespace, verify the user actually has push/admin access to that specific repository (not just organization membership)

## Files Involved

- `entity/user.v` - `github_token` field (refreshed on every login)
- `entity/organization.v` - `UserOrganization` entity
- `repo/users.v` - `update_github_token`; `migrate_users` also adds `github_token` to an existing `user` table
- `repo/organization.v` - database operations for organizations (`save_user_organizations` replaces a user's membership list atomically)
- `auth.v` - fetches org memberships and persists the OAuth token during login
- `usecase/package/packages.v` - organization URL/prefix support, repo-level permission check (`require_repo_write_access`)
- `package.v` / `package_api.v` - pass the logged in user through to the create/update use cases

## How It Works

1. When a user logs in via GitHub OAuth, we fetch their organization memberships using the GitHub API (`/user/orgs`, paginated) and persist their OAuth token
2. Organizations are stored in the `userorganization` table, replacing the user's entire membership list atomically on each login
3. If the org membership fetch itself fails (GitHub outage, rate limit, etc.), the existing membership list is left untouched rather than replaced with an empty one, login still proceeds
4. When creating or updating a package:
   - The URL is validated against the user's own account, their organizations or admin status (`is_admin`)
   - If the URL belongs to an organization, we additionally verify, via the user's stored GitHub token, that they have push/admin access to that *specific* repository.
   - If the URL belongs to an organization, the package name uses the org name as prefix (e.g., `v-hono.hono` instead of `meiseayoung.hono`)

## Example

User `meiseayoung` is a member of the `v-hono` organization and has push access to `v-hono/v-hono-core`.

Before this change:
- Publishing `https://github.com/v-hono/v-hono-core` would fail with "You must submit a package from your own account"

After this change:
- Publishing `https://github.com/v-hono/v-hono-core` with name `hono` creates package `v-hono.hono`
- Publishing a `v-hono` repository the user does *not* have push access to still fails, even though they're a member of the organization

## Database Migration

`repo.migrate()` runs on application startup and automatically creates or updates these tables, so manual migration is normally unnecessary.
For deployments where the application database user can't execute DDL and the schema must be provisioned separately, use the lowercase identifiers expected by the ORM rather than the PascalCase struct names. The schema below reflects the current application model.

```sql
CREATE TABLE IF NOT EXISTS userorganization (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    org_name TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_userorganization_user_id ON userorganization (user_id);

-- If upgrading an existing `user` table that predates github_token:
ALTER TABLE "user" ADD COLUMN IF NOT EXISTS github_token TEXT NOT NULL DEFAULT '';
```

## GitHub OAuth Scope

The GitHub OAuth app needs the `read:org` scope to access organization memberships already included in `login_link()`'s authorization URL:

```
https://github.com/login/oauth/authorize?response_type=code&client_id={CLIENT_ID}&scope=read:org
```
