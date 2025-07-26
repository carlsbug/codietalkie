import Foundation

struct AppConfig {
    // GitHub OAuth Configuration - REPLACE WITH YOUR VALUES
    static let githubClientId = "YOUR_GITHUB_CLIENT_ID" // Get from GitHub Developer Settings
    static let githubClientSecret = "YOUR_GITHUB_CLIENT_SECRET" // Get from GitHub Developer Settings
    static let githubRedirectUri = "githubvoiceassistant://oauth/callback"
    static let githubScope = "repo,user"
    
    // LLM API Configuration - REPLACE WITH YOUR VALUES
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY" // Get from OpenAI Platform
    static let openAIModel = "gpt-4"
    static let openAIBaseURL = "https://api.openai.com/v1"
    
    // Configuration validation
    static var isGitHubConfigured: Bool {
        return githubClientId != "YOUR_GITHUB_CLIENT_ID" && 
               githubClientSecret != "YOUR_GITHUB_CLIENT_SECRET" &&
               !githubClientId.isEmpty && 
               !githubClientSecret.isEmpty
    }
    
    static var isOpenAIConfigured: Bool {
        return openAIAPIKey != "YOUR_OPENAI_API_KEY" && 
               !openAIAPIKey.isEmpty
    }
    
    static var isFullyConfigured: Bool {
        return isGitHubConfigured && isOpenAIConfigured
    }
    
    // App Settings
    static let keychainService = "com.githubvoiceassistant.tokens"
    static let keychainAccessGroup = "group.com.githubvoiceassistant.shared"
    
    // Speech Recognition Settings
    static let speechRecognitionTimeout: TimeInterval = 30.0
    static let speechRecognitionLocale = "en-US"
    
    // GitHub API Settings
    static let githubAPIBaseURL = "https://api.github.com"
    static let requestTimeout: TimeInterval = 30.0
    
    // UI Settings
    static let maxRepositoriesDisplayed = 50
    static let maxFileChangesDisplayed = 10
    static let animationDuration: Double = 0.3
}

// MARK: - Environment-specific configurations
extension AppConfig {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var logLevel: LogLevel {
        return isDebug ? .debug : .error
    }
}

enum LogLevel {
    case debug
    case info
    case warning
    case error
}
