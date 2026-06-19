# Fastlane Gotchas — getting deliver/supply to actually run

The environment problems that block a first fastlane upload, with fixes.

## Ruby / bundler

The macOS **system ruby 2.6** `~/.gem` install is usually broken (e.g. fastlane is
present but `gh_inspector` and friends are missing). Use **Homebrew ruby 3.4+** with
bundler and always `bundle exec`:

```bash
brew install ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
gem install bundler
cd ios   && bundle install && bundle exec fastlane release_listing
cd android && bundle install && bundle exec fastlane internal
```

Pin fastlane in a `Gemfile` (see `templates/*/Gemfile`) so CI and local match.

## Locale (deliver only)

`deliver` reads metadata files as the shell's encoding. Non-ASCII locales
(vi/ja/ko/zh/…) under a non-UTF-8 locale crash with
`Encoding::CompatibilityError: invalid byte sequence in US-ASCII`. Always:

```bash
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
```

## App Store Connect API key

- `deliver`/`supply` Fastfiles read `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`.
- Each Bash invocation is a fresh shell — set the env vars in the **same** command
  as `bundle exec`, or they'll be nil in the ruby subprocess.
- The `.p8` lives at `~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8` (mode 600).
- The API key role **cannot create app records** (403) — make the app in the web UI first.

## First-version spaceship fixes

Run these once via `bundle exec fastlane spaceship` or a small ruby script when a
brand-new version blocks deliver:

```ruby
require 'spaceship'
token = Spaceship::ConnectAPI::Token.create(
  key_id: ENV['ASC_KEY_ID'],
  issuer_id: ENV['ASC_ISSUER_ID'],
  filepath: ENV['ASC_KEY_P8']
)
Spaceship::ConnectAPI.token = token

app = Spaceship::ConnectAPI::App.find(ENV.fetch('BUNDLE_ID', 'com.example.myapp'))
ver = app.get_edit_app_store_version  # the editable PREPARE_FOR_SUBMISSION version

# Fix #1: version string must equal the build's CFBundleShortVersionString
ver.update(attributes: { version_string: '3.0.1' })

# Fix #2: first version has no review-detail object → deliver's fetch crashes
ver.create_app_store_review_detail(attributes: { demo_account_required: false })
```

## Supply (Android) service account

```bash
export SUPPLY_JSON_KEY="/abs/path/play-store-service-account.json"
```
The service account needs "Release manager" in the Play Console. Metadata-only runs
must skip changelogs (they require a versionCode): the `metadata` lane sets
`skip_upload_changelogs: true`.

## Screenshots

- iOS: `deliver` occasionally reports screenshots missing on the first try and
  succeeds on auto-retry — let it retry.
- Only the locales with screenshot folders get uploaded; others fall back to `en-US`.
