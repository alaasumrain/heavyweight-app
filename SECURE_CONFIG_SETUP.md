# 🔐 Secure Configuration Setup

This app now uses Flutter 2025 security best practices for handling API credentials using compile-time constants instead of runtime environment files.

## Quick Start

1. **Copy the example configuration:**
   ```bash
   cp env.json.example env.json
   ```

2. **Update env.json with your credentials:**
   ```json
   {
     "SUPABASE_URL": "https://your-project.supabase.co",
     "SUPABASE_ANON_KEY": "your_anon_key_here"
   }
   ```

3. **Run the app with secure credentials:**
   ```bash
   flutter run --dart-define-from-file=env.json
   ```

4. **Build for release with secure credentials:**
   ```bash
   flutter build apk --dart-define-from-file=env.json
   ```

## Security Benefits

✅ **Compile-time constants**: Credentials are embedded at build time, making them harder to extract
✅ **No runtime file reading**: Better performance and security than .env files  
✅ **Git-safe**: env.json is ignored by git, preventing accidental commits
✅ **Validation**: App validates credentials before initialization
✅ **No hardcoded secrets**: Source code contains no sensitive information

## Migration from .env

The old `.env` file approach has been completely removed. The app now requires `--dart-define-from-file=env.json` to run.

## Troubleshooting

**Error: "SUPABASE_URL not configured"**
- Ensure you're running with `--dart-define-from-file=env.json`
- Check that env.json exists and contains valid credentials

**Error: "Failed to initialize Supabase"**  
- Verify your Supabase URL starts with `https://`
- Check that your anon key is correct and not expired

## Development Team Setup

1. Each developer should copy `env.json.example` to `env.json`
2. Update `env.json` with their development credentials
3. Never commit `env.json` to version control

## Production Deployment

Use your CI/CD system to create `env.json` from secure environment variables before building.