# 🎤 codietalkie - Voice-to-Code-to-GitHub Setup Guide

Transform your voice commands into working code and automatically push to GitHub!

## ⚡ Quick Setup (5 minutes)

### 1. Copy Credentials File
```bash
cp codietalkie/Shared/Configuration/Credentials.template.swift codietalkie/Shared/Configuration/Credentials.swift
```

### 2. Get GitHub Token
1. Go to [GitHub Settings → Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `user`
4. Copy the token (starts with `ghp_`)
5. Replace `"ghp_your_github_token_here"` in `Credentials.swift`

### 3. Get Hugging Face Token (FREE)
1. Sign up at [huggingface.co](https://huggingface.co) (free)
2. Go to [Settings → Access Tokens](https://huggingface.co/settings/tokens)
3. Create new token
4. Copy the token (starts with `hf_`)
5. Replace `"hf_your_huggingface_token_here"` in `Credentials.swift`

### 4. Update Username
Replace `"your_github_username"` with your actual GitHub username in `Credentials.swift`

### 5. Run the App
- Build and run in Xcode
- Say "Create a basic calculator" into your Apple Watch
- Watch the magic happen! 🎉

## 🎯 What It Does

### Complete Voice-to-Code-to-GitHub Pipeline:
1. **🎤 Voice Input**: Say "Create a basic calculator"
2. **🔊 Speech Recognition**: Converts voice to text
3. **🤖 AI Code Generation**: Hugging Face CodeLlama generates code
4. **📁 Repository Creation**: Creates new GitHub repository
5. **💾 File Upload**: Commits and pushes all files
6. **✅ Success**: Shows completion on Apple Watch

## 🛠 Features

### ✅ Real Functionality:
- **Apple Speech Recognition**: Real voice-to-text conversion
- **Hugging Face LLM**: Free AI code generation using CodeLlama
- **GitHub API Integration**: Real repository and file operations
- **Template Fallbacks**: Works offline with pre-built templates
- **Error Handling**: Robust error recovery and user feedback

### 🎨 Supported Project Types:
- **Calculator**: HTML/CSS/JavaScript calculator
- **Todo List**: Task management app
- **Weather App**: Weather display with demo data
- **Timer**: Countdown timer application

## ⚙️ Configuration Options

### Demo Mode (No API Keys Required)
```swift
static let demoMode = true  // Uses templates instead of APIs
```

### Verbose Logging (For Debugging)
```swift
static let verboseLogging = true  // Shows detailed API logs
```

### Template Fallbacks
```swift
static let useLocalTemplates = true  // Fallback when API fails
```

## 🔧 Troubleshooting

### Common Issues:

**"Cannot find APICredentials"**
- Make sure you copied `Credentials.template.swift` to `Credentials.swift`
- Check that `Credentials.swift` is added to your Xcode project

**"Invalid Credentials"**
- Verify GitHub token has `repo` and `user` permissions
- Ensure Hugging Face token is valid
- Check that tokens don't contain "your_" placeholder text

**"API Rate Limit"**
- GitHub: 5000 requests/hour (very generous)
- Hugging Face: ~1000 requests/month (sufficient for demos)

**Speech Recognition Not Working**
- Grant microphone permissions to the app
- Ensure Apple Watch is connected to iPhone
- Try speaking clearly and close to the Watch

## 🎮 Demo Mode

Perfect for presentations without internet:

1. Set `demoMode = true` in `Credentials.swift`
2. App uses pre-built templates instead of API calls
3. Still shows realistic processing delays
4. Great for showcasing the user experience

## 📱 Architecture

### Watch App:
- Voice input and user interface
- Speech recognition
- Status display and navigation

### iPhone Companion:
- Heavy processing (LLM calls, GitHub operations)
- Network requests and file operations
- Background processing

### Shared Services:
- **LLMService**: Hugging Face API + template fallbacks
- **GitHubAPIClient**: Complete GitHub API integration
- **WatchConnectivityManager**: Real-time sync
- **CodeTemplates**: Pre-built project templates

## 🚀 Usage Examples

### Voice Commands:
- "Create a basic calculator"
- "Make a todo list app"
- "Build a weather application"
- "Generate a timer app"

### Expected Output:
- New GitHub repository created
- Multiple files (HTML, CSS, JS, README)
- Working, deployable code
- Professional project structure

## 🔐 Security

- Credentials stored locally only
- `Credentials.swift` excluded from git
- Tokens never logged or transmitted except to APIs
- GitHub tokens can be revoked anytime

## 🎉 Success!

Once set up, you can literally speak into your Apple Watch and have working code automatically created and pushed to GitHub. It's like having an AI coding assistant on your wrist!

---

**Need help?** Check the verbose logs or create an issue with your setup details.

**Ready to code with your voice?** 🎤→💻→🚀
