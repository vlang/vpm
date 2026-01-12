# VPM Organization Support Feature

## Problem

Currently, VPM only allows users to publish packages from repositories under their own GitHub account. The validation in `check_vcs()` function requires the repository URL to start with `https://github.com/{username}/`, where `username` is the logged-in user's GitHub username.

This prevents users from publishing packages from GitHub organizations they belong to.

## Solution Overview

1. Add a new database table to store user's GitHub organization memberships
2. Fetch user's organizations during OAuth login
3. Modify `check_vcs()` to also accept organization URLs where the user is a member
4. Automatically use organization name as package prefix when publishing from org repos

## Files Changed

### New Files
- `src/entity/organization.v` - UserOrganization entity
- `src/repo/organization.v` - Database operations for organizations

### Modified Files
- `src/auth.v` - Fetch user's organizations during OAuth login
- `src/usecase/package/packages.v` - Support organization URLs and prefixes
- `src/package.v` - Pass organization info to create function

## How It Works

1. When a user logs in via GitHub OAuth, we fetch their organization memberships using the GitHub API (`/user/orgs`)
2. Organizations are stored in the `UserOrganization` table
3. When creating a package:
   - The URL is validated against both the user's account AND their organizations
   - If the URL belongs to an organization, the package name uses the org name as prefix (e.g., `v-hono.hono` instead of `meiseayoung.hono`)

## Example

User `meiseayoung` is a member of the `v-hono` organization.

Before this change:
- Publishing `https://github.com/v-hono/v-hono-core` would fail with "You must submit a package from your own account"

After this change:
- Publishing `https://github.com/v-hono/v-hono-core` with name `hono` creates package `v-hono.hono`

## Database Migration

Run the following to create the new table:

```sql
CREATE TABLE IF NOT EXISTS "UserOrganization" (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    org_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_org_user_id ON "UserOrganization" (user_id);
```

## GitHub OAuth Scope

Note: The GitHub OAuth app may need the `read:org` scope to access organization memberships. Update the OAuth authorization URL if needed:

```
https://github.com/login/oauth/authorize?response_type=code&client_id={CLIENT_ID}&scope=read:org
```
