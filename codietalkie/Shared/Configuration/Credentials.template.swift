//
//  Credentials.template.swift
//  codietalkie
//
//  Template file for API credentials
//  Copy this to Credentials.swift and add your actual tokens
//

import Foundation

struct APICredentials {
    // MARK: - GitHub Configuration
    /// Your GitHub Personal Access Token
    /// Get it from: https://github.com/settings/tokens
    /// Required permissions: repo, user
    static let githubToken = "ghp_your_github_token_here"
    
    /// Your GitHub username
    static let githubUsername = "your_github_username"
    
    // MARK: - LLM Service Configuration
    /// Hugging Face API Token (FREE)
    /// Get it from: https://huggingface.co/settings/tokens
    static let huggingFaceToken = "hf_your_huggingface_token_here"
    
    /// LLM Model to use for code generation
    static let llmModel = "codellama/CodeLlama-7b-Instruct-hf"
    
    // MARK: - Demo Configuration
    /// Set to true for offline demo mode (uses templates instead of API)
    static let demoMode = false
    
    /// Use local templates as fallback when API fails
    static let useLocalTemplates = true
    
    /// Simulate processing delays for realistic demo feel
    static let simulateDelay = true
    
    /// Enable verbose logging for debugging
    static let verboseLogging = true
}

// MARK: - Setup Instructions
/*
 QUICK SETUP (5 minutes):
 
 1. COPY THIS FILE:
    - Copy this file to "Credentials.swift" (remove .template)
    - Add Credentials.swift to .gitignore (already done)
 
 2. GET GITHUB TOKEN:
    - Go to https://github.com/settings/tokens
    - Click "Generate new token (classic)"
    - Select scopes: repo, user
    - Copy token and replace "ghp_your_github_token_here"
 
 3. GET HUGGING FACE TOKEN:
    - Sign up at https://huggingface.co (FREE)
    - Go to https://huggingface.co/settings/tokens
    - Create new token
    - Copy token and replace "hf_your_huggingface_token_here"
 
 4. UPDATE USERNAME:
    - Replace "your_github_username" with your actual GitHub username
 
 5. RUN THE APP:
    - Everything else works automatically!
    - Say "Create a basic calculator" and watch the magic happen!
 
 DEMO MODE:
 - Set demoMode = true for offline demonstrations
 - Uses pre-built templates instead of API calls
 - Perfect for presentations without internet
 
 TROUBLESHOOTING:
 - Check tokens are valid and have correct permissions
 - Ensure GitHub username matches your account
 - Enable verboseLogging = true for detailed error messages
 */
