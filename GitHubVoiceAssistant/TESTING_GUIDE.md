# 🧪 Testing Guide for GitHub Voice Assistant

## 📱 Quick Start in Xcode

### Step 1: Open Project
The project should now be open in Xcode. If not, double-click `GitHubVoiceAssistant.xcodeproj`

### Step 2: Configure Build Settings
1. **Select your Development Team**:
   - Click on the project name in the navigator
   - Select "GitHubVoiceAssistant" target
   - Go to "Signing & Capabilities"
   - Select your Apple Developer account under "Team"

2. **Update Bundle Identifiers** (if needed):
   - iOS App: `com.yourname.githubvoiceassistant`
   - Watch App: `com.yourname.githubvoiceassistant.watchkitapp`

### Step 3: Build the Project
1. **Select Target**: Choose "GitHubVoiceAssistant" scheme
2. **Select Device**: Choose your iPhone (or iOS Simulator for basic testing)
3. **Build**: Press `⌘ + B` or click the Build button

### Step 4: Test Basic Functionality

#### 🎯 Test 1: iOS Companion App
1. **Run iOS App**: Press `⌘ + R`
2. **Expected Result**: 
   - App launches with "GitHub Voice Assistant Companion" title
   - Shows "Sign In with GitHub" button
   - Shows "Apple Watch not reachable" (normal in simulator)

#### 🎯 Test 2: Watch App (Simulator)
1. **Change Target**: Select "GitHubVoiceAssistant WatchKit App" scheme
2. **Select Watch Simulator**: Choose Apple Watch simulator
3. **Run**: Press `⌘ + R`
4. **Expected Result**:
   - Watch app launches with authentication screen
   - Shows "Sign in with your iPhone" message

#### 🎯 Test 3: Build Tests
1. **Run Tests**: Press `⌘ + U`
2. **Expected Result**: Unit tests should pass

## 🔧 Common Issues & Solutions

### Issue 1: Build Errors
**Problem**: "No such module" errors
**Solution**: 
- Clean build folder: `⌘ + Shift + K`
- Rebuild: `⌘ + B`

### Issue 2: Signing Issues
**Problem**: Code signing errors
**Solution**:
- Ensure you have a valid Apple Developer account
- Update bundle identifiers to be unique
- Select correct development team

### Issue 3: Watch Connectivity
**Problem**: "Watch not reachable" in simulator
**Solution**: This is normal - Watch Connectivity only works on physical devices

## 📋 Testing Checklist

### ✅ Basic Functionality
- [ ] iOS app builds successfully
- [ ] Watch app builds successfully  
- [ ] Unit tests pass
- [ ] UI displays correctly in simulators

### ✅ Advanced Testing (Requires Physical Devices)
- [ ] iPhone and Apple Watch paired
- [ ] Watch Connectivity working
- [ ] Authentication flow (requires GitHub OAuth setup)
- [ ] Speech recognition (requires microphone permissions)
- [ ] End-to-end voice-to-code flow

## 🚀 Next Steps for Full Testing

1. **Set up GitHub OAuth**:
   - Create GitHub OAuth app
   - Update `AppConfig.swift` with credentials

2. **Set up OpenAI API**:
   - Get OpenAI API key
   - Update `AppConfig.swift` with key

3. **Test on Physical Devices**:
   - Deploy to iPhone and paired Apple Watch
   - Test complete voice-to-code workflow

## 🎯 Expected Behavior

### iOS Companion App
- Clean, simple interface
- GitHub authentication button
- Watch connectivity status
- Sign out functionality

### Apple Watch App
- Authentication screen initially
- Main dashboard after auth
- Repository selection
- Voice input interface
- Code review screen

The app is designed to be simple and intuitive, optimized for Apple Watch interaction patterns.