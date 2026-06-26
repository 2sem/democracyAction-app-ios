---
name: release-ios-testflight
description: Use when preparing an iOS TestFlight release branch, bumping MARKETING_VERSION, creating a release PR, running deploy-ios.yml, and monitoring the GitHub Actions deployment.
---

# Release iOS TestFlight

Use this skill when the user asks to release the next app version, run `/release`, prepare TestFlight, or deploy a version branch.

## Inputs

- Version format: semantic `a.b.c`, for example `2.1.2`.
- If the user provides a version, use it exactly.
- If no version is provided, read `MARKETING_VERSION` from both config files and increment the patch version.
- Release notes may be provided by the user. If not, generate concise release notes from merged PRs and commits since the previous version bump or latest relevant release commit.

## Files To Update

- `Projects/App/Configs/debug.xcconfig`
- `Projects/App/Configs/release.xcconfig`

Update only `MARKETING_VERSION=<a.b.c>` in both files. Do not change `CURRENT_PROJECT_VERSION`; the deploy workflow/fastlane increments the TestFlight build number.

## Branch And PR

1. Start from a clean `main` synced with `origin/main`.
2. Create a release branch named exactly the version string, for example `2.1.2`.
3. Update app version in both xcconfig files.
4. Commit with message `chore(release): prepare <a.b.c>`.
5. Push the branch.
6. Create a PR into `main` titled `Release <a.b.c>`.
7. Use the release notes as the PR body.

## Validation Before Deploy

- Inspect `git status`, `git diff`, and recent commits before committing.
- Verify the PR includes only the intended version config changes unless the user explicitly asked for more.
- Run `git diff --check`.
- Do not include unrelated `.package.resolved`, `.opencode`, workbook, photo, or secret changes.
- If local build validation is blocked by known package resolver issues, document the exact blocker in the PR body and final report.

## Deploy To TestFlight

After the PR exists, run the deploy workflow using the version branch as the ref:

```bash
gh workflow run deploy-ios.yml \
  --ref <a.b.c> \
  -f isReleasing=false \
  -f body='<release notes>'
```

Use `isReleasing=false` for TestFlight. Do not set `isReleasing=true` unless the user explicitly asks to submit for App Store review.

## Monitor Deployment

1. Find the workflow run for the branch:

```bash
gh run list --workflow deploy-ios.yml --branch <a.b.c> --limit 5
```

2. Watch the run until it completes:

```bash
gh run watch <run-id> --exit-status
```

3. If the run succeeds, report that the release task is done and include:
   - Version
   - Branch
   - PR URL
   - Deploy run URL
   - Final workflow status

4. If the run fails, report the failed step and key error output. Do not claim the task is done.

## Important Rules

- Never merge the release PR unless the user explicitly asks to merge it.
- Never submit for App Store review unless explicitly requested.
- Preserve unrelated untracked files.
- Do not revert user changes.
- If the working tree has unrelated tracked changes, stop and ask how to proceed before creating the release branch.
