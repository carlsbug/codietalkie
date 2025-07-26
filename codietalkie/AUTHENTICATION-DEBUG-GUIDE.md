# Watch App Authentication Debugging Guide

## Enhanced Debug Features

The watch app now includes comprehensive debugging capabilities for the `checkAuthentication()` function. Here's how to use them:

## Debug Output Explained

### 1. Authentication Check Header
```
Watch: ===== AUTHENTICATION CHECK [1706198400.123] =====
```
- Shows timestamp for tracking multiple authentication attempts
- Helps identify timing issues

### 2. Current State Debug
```
Watch: Current State - isAuthenticated: false, currentView: authentication
```
- Shows the app's current authentication state
- Helps identify state inconsistencies

### 3. UserDefaults Debug Information
```
Watch: 📊 UserDefaults Debug Information:
Watch: github_token_shared: (not set)
Watch: github_token_watch: (not set)
Watch: github_token: (not set)
Watch: github_username_shared: (not set)
Watch: github_username_watch: (not set)
Watch: ✅ UserDefaults is working correctly
```
- Shows all relevant UserDefaults keys and their status
- Tests UserDefaults functionality
- Identifies storage issues

### 4. Token Discovery Process
```
Watch: 🔍 Found token via shared UserDefaults
Watch: Token prefix: ghp_1234567...
Watch: Token length: 40
Watch: ✅ Token format is valid
```
- Shows which storage location contained a token
- Displays token prefix for identification (safe logging)
- Validates token format before API calls

### 5. API Validation Process
```
Watch: 🌐 Validating token from shared storage with GitHub API...
Watch: Making API request to validate token...
Watch: API Response Status: 200
Watch: ✅ Token validated successfully for user: @username
```
- Shows real-time API validation
- Displays HTTP status codes
- Shows authenticated username

### 6. Error Scenarios
```
Watch: ❌ Invalid token format in shared storage
Watch: ❌ API validation failed: 401
Watch: Response: {"message":"Bad credentials"}
```
- Clear error messages for different failure modes
- HTTP status codes and response bodies
- Helps identify specific issues

## How to Debug Authentication Issues

### Step 1: Check Console Output
1. Run the watch app in Xcode
2. Open the Console (View → Debug Area → Console)
3. Look for the authentication debug output

### Step 2: Analyze Token Storage
Look for these patterns in the debug output:

**No Tokens Found:**
```
Watch: github_token_shared: (not set)
Watch: github_token_watch: (not set)
Watch: github_token: (not set)
```
**Solution:** Authenticate on iPhone first, or use Demo Mode

**Token Found but Invalid Format:**
```
Watch: Token prefix: abc_1234567...
Watch: ❌ Invalid token format in shared storage
```
**Solution:** Check that the token starts with `ghp_` or `github_pat_`

**Token Found but API Validation Failed:**
```
Watch: ✅ Token format is valid
Watch: ❌ API validation failed: 401
```
**Solution:** Token may be expired or invalid - generate a new one

### Step 3: Test UserDefaults Functionality
The debug output includes a UserDefaults test:
```
Watch: ✅ UserDefaults is working correctly
```
If this shows an error, there may be a system-level issue.

### Step 4: Check Network Connectivity
If API validation fails, check:
- Watch has internet connection
- GitHub API is accessible
- No firewall/proxy issues

## Common Debug Scenarios

### Scenario 1: "No token found in any storage location"
**Debug Output:**
```
Watch: ❌ No token found in shared UserDefaults
Watch: ❌ No token found in watch UserDefaults
Watch: ❌ No token found in legacy UserDefaults
Watch: ❌ Credentials file not accessible from watch app
```
**Solutions:**
1. Use "Demo Mode" for immediate testing
2. Authenticate on iPhone app
3. Manually set token in UserDefaults for testing

### Scenario 2: Token exists but authentication fails
**Debug Output:**
```
Watch: 🔍 Found token via shared UserDefaults
Watch: Token prefix: ghp_1234567...
Watch: ❌ API validation failed: 401
```
**Solutions:**
1. Check if token is expired
2. Verify token has correct permissions (repo, user)
3. Generate new token from GitHub

### Scenario 3: iPhone-Watch sync not working
**Debug Output:**
```
Watch: github_token_shared: (not set)
Watch: github_token_watch: (not set)
```
**Solutions:**
1. Check if iPhone app is properly storing tokens
2. Verify UserDefaults synchronization
3. Use WatchConnectivity for real-time sync

## Manual Testing Commands

### Set Test Token (for debugging)
```bash
# Set a test token in shared storage
defaults write com.yourcompany.codietalkie github_token_shared "ghp_test_token_here"

# Set username
defaults write com.yourcompany.codietalkie github_username_shared "testuser"
```

### Clear All Tokens
```bash
# Clear all authentication data
defaults delete com.yourcompany.codietalkie github_token_shared
defaults delete com.yourcompany.codietalkie github_token_watch
defaults delete com.yourcompany.codietalkie github_token
```

### Check Current Storage
```bash
# View all stored tokens
defaults read com.yourcompany.codietalkie | grep github
```

## Debug Features Summary

✅ **Comprehensive Logging** - Every step is logged with clear messages
✅ **Token Format Validation** - Checks GitHub token format before API calls
✅ **API Validation** - Actually validates tokens with GitHub API
✅ **UserDefaults Testing** - Verifies storage functionality
✅ **Multiple Token Sources** - Checks all possible storage locations
✅ **Error Categorization** - Different error types with specific solutions
✅ **Safe Token Logging** - Only shows token prefixes for security
✅ **Timestamp Tracking** - Helps identify timing issues

The enhanced debugging should help you quickly identify and resolve authentication issues in the watch app.
