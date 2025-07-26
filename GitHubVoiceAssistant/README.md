# GitHub Voice Assistant

A native Apple Watch application that enables hands-free coding through voice commands. The app integrates with GitHub repositories, processes voice input through LLM agents, and commits code changes directly to GitHub.

## 🎯 Features

### MVP Core Flow
1. **GitHub Authentication** - OAuth through iPhone companion app
2. **Voice Input** - Speech-to-text using Apple's Speech Recognition
3. **LLM Processing** - Natural language to code generation
4. **Repository Management** - Select existing or create new repositories
5. **Code Review & Commit** - Review changes and push to GitHub

## 📱 Project Structure

```
GitHubVoiceAssistant/
├── GitHubVoiceAssistant/                    # iOS Companion App
│   ├── GitHubVoiceAssistantApp.swift
│   ├── ContentView.swift
│   └── Services/
│       └── GitHubAuthService.swift
├── GitHubVoiceAssistant WatchKit App/       # Apple Watch App
│   ├── GitHubVoiceAssistant_Watch_AppApp.swift
│   ├── ContentView.swift
│   ├── Coordinators/
│   │   └── AppCoordinator.swift
│   ├── Views/
│   │   ├── AuthenticationView.swift
│   │   ├── MainDashboardView.swift
│   │   ├── RepositorySelectionView.swift
│   │   ├── VoiceInputView.swift
│   │   └── CodeReviewView.swift
│   └── Services/
│       └── SpeechRecognitionService.swift
├── Shared/                                  # Shared Code
│   ├── Models/                             # Data Models
│   │   ├── GitHubToken.swift
│   │   ├── Repository.swift
│   │   ├── VoiceRequest.swift
│   │   └── FileChange.swift
│   ├── Services/                           # Core Services
│   │   ├── WatchConnectivityManager.swift
│   │   ├── KeychainManager.swift
│   │   ├── GitHubAPIClient.swift
│   │   └── LLMService.swift
│   └── Configuration/
│       └── AppConfig.swift
└── GitHubVoiceAssistantTests/              # Tests
    └── IntegrationTests.swift
```

## 🚀 Quick Start

### Prerequisites
- iOS 17.0+
- watchOS 10.0+
- Xcode 15.0+
- GitHub account
- OpenAI API key

### Setup Instructions

1. **Clone and Open Project**
   ```bash
   git clone <repository-url>
   cd GitHubVoiceAssistant
   open GitHubVoiceAssistant.xcodeproj
   ```

2. **Configure GitHub OAuth**
   - Go to GitHub Settings → Developer settings → OAuth Apps
   - Create a new OAuth App with:
     - Application name: "GitHub Voice Assistant"
     - Authorization callback URL: `githubvoiceassistant://oauth/callback`
   - Copy Client ID and Client Secret
   - Update `AppConfig.swift` with your credentials

3. **Configure OpenAI API**
   - Get your OpenAI API key from https://platform.openai.com/api-keys
   - Update `AppConfig.swift` with your API key

4. **Configure Bundle Identifiers**
   - Set your development team in Xcode
   - Update bundle identifiers:
     - iOS app: `com.yourteam.githubvoiceassistant`
     - Watch app: `com.yourteam.githubvoiceassistant.watchkitapp`

5. **Build and Run**
   - Select your iPhone as the target device
   - Build and run the project
   - The watch app will automatically install on paired Apple Watch

## 🏗️ Architecture

The app follows **MVVM pattern** with:

- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for data flow
- **WatchConnectivity** - Communication between iPhone and Watch
- **Keychain Services** - Secure token storage
- **Speech Framework** - Voice recognition
- **URLSession** - Network requests to GitHub and OpenAI APIs

### Key Components

- **AppCoordinator** - Manages app navigation and state
- **GitHubAuthService** - Handles OAuth authentication
- **SpeechRecognitionService** - Processes voice input
- **LLMService** - Integrates with OpenAI for code generation
- **GitHubAPIClient** - Manages GitHub API interactions
- **WatchConnectivityManager** - Syncs data between devices

## 🎙️ Usage

1. **Authentication**
   - Open the iPhone companion app
   - Tap "Sign In with GitHub"
   - Complete OAuth flow in browser
   - Token automatically syncs to Apple Watch

2. **Voice Coding**
   - Open the watch app
   - Select or create a repository
   - Tap the voice button
   - Speak your coding request (e.g., "Create a hello world function in Swift")
   - Review the generated code
   - Approve to commit to GitHub

## 🧪 Testing

Run the test suite:
```bash
# In Xcode
⌘ + U
```

The project includes:
- **Unit Tests** - Individual component testing
- **Integration Tests** - End-to-end workflow testing
- **UI Tests** - User interface testing

## 🔧 Configuration

Key settings in `AppConfig.swift`:

```swift
// GitHub OAuth
static let githubClientId = "YOUR_GITHUB_CLIENT_ID"
static let githubClientSecret = "YOUR_GITHUB_CLIENT_SECRET"

// OpenAI API
static let openAIAPIKey = "YOUR_OPENAI_API_KEY"
static let openAIModel = "gpt-4"

// Speech Recognition
static let speechRecognitionTimeout: TimeInterval = 30.0
static let speechRecognitionLocale = "en-US"
```

## 🚨 Troubleshooting

### Common Issues

1. **Watch Connectivity Issues**
   - Ensure both iPhone and Watch are on same WiFi
   - Restart both devices
   - Check Watch app is installed

2. **Authentication Failures**
   - Verify GitHub OAuth app configuration
   - Check redirect URI matches exactly
   - Ensure client ID/secret are correct

3. **Speech Recognition Not Working**
   - Grant microphone permissions
   - Check Watch is not in silent mode
   - Ensure clear speech in quiet environment

4. **LLM API Errors**
   - Verify OpenAI API key is valid
   - Check API quota/billing
   - Monitor rate limits

## 🔮 Future Enhancements

- **Activity Logging** - Track all voice requests and commits
- **Advanced Repository Management** - Search, filtering, caching
- **Offline Support** - Limited functionality without internet
- **Multiple LLM Providers** - Support for Anthropic, local models
- **Voice Commands** - Repository selection via voice
- **Haptic Feedback** - Enhanced user experience
- **Accessibility** - VoiceOver support

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

---

**Ready to code with your voice! 🎙️⌚️**