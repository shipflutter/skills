# Add Feature Reference

## Required repo artifacts
- `resources/implement_feat_readme.md`
- `resources/user-story/epXX-<feature>.md`
- `resources/technial-design/epXX-<feature>.md`
- `resources/templates/add-feat/`

## Feature flow
1. Create or update user-story doc.
2. Create or update technical-design doc.
3. Implement UI -> bloc -> usecase -> repository/service.
4. Add integration service boundary for API/platform calls.
5. Mock the integration layer in unit/integration tests.
6. Add screenshot e2e runner and include it in SRS traceability.

## Sign-in API template
Use `assets/templates/sign-in-api-service-ft-integration.md` when the feature uses a service API.

## gen-tdd script
Run:
```bash
skills/add-feat/scripts/add_feat.sh gen-tdd <feature-slug> <EPXX>
```

The script scans `lib/presentation/<feature-slug>` and creates:
- `resources/user-story/epXX-<feature-slug>.md`
- `resources/technial-design/epXX-<feature-slug>.md`
