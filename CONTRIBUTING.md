# Contributing

## Development setup

1. Install Flutter stable.
2. Run:
   ```bash
   flutter pub get
   ```
3. Configure Firebase for your environment:
   ```bash
   flutterfire configure
   ```

## Code style

- Follow `analysis_options.yaml`.
- Keep changes focused and small.
- Prefer clear naming and minimal complexity.

## Before opening a pull request

Run:

```bash
flutter analyze
flutter test
```

If tests are not available yet, include manual validation steps in your PR.

## Pull request checklist

- [ ] Changes are scoped and documented
- [ ] Analyzer passes locally
- [ ] Tests pass or manual verification is provided
- [ ] No secrets or credentials were added
