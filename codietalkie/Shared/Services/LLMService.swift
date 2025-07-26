//
//  LLMService.swift
//  codietalkie
//
//  Service for interacting with Large Language Models
//  Supports Claude API and local templates
//

import Foundation
import Combine

// Import credentials configuration
// Note: APICredentials is defined in Credentials.swift

// MARK: - Claude API Response Models
struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
    let id: String
    let model: String
    let role: String
    let stop_reason: String?
    let stop_sequence: String?
    let type: String
    let usage: ClaudeUsage
}

struct ClaudeContent: Codable {
    let text: String
    let type: String
}

struct ClaudeUsage: Codable {
    let input_tokens: Int
    let output_tokens: Int
}

// MARK: - API Endpoints Configuration
struct APIEndpoints {
    // MARK: - Claude API Configuration
    static let claudeBaseURL = "https://api.anthropic.com/v1/messages"
    
    static func claudeHeaders(apiKey: String) -> [String: String] {
        return [
            "x-api-key": apiKey,
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        ]
    }
    
    struct RequestConfig {
        static let timeoutInterval: TimeInterval = 30.0
    }
    
    struct ClaudeConfig {
        static let maxTokens = 4000
        static let temperature = 0.7
        static let model = "claude-3-5-sonnet-20241022"
    }
}

// MARK: - Code Templates
struct CodeTemplates {
    static func findTemplate(for request: String) -> Template? {
        let lowercased = request.lowercased()
        
        if lowercased.contains("calculator") || lowercased.contains("calc") {
            return calculatorTemplate
        } else if lowercased.contains("todo") || lowercased.contains("task") {
            return todoTemplate
        } else if lowercased.contains("weather") {
            return weatherTemplate
        } else if lowercased.contains("hello") && lowercased.contains("ai") {
            return helloAITemplate
        }
        
        // Default template
        return basicWebTemplate
    }
    
    struct Template {
        let name: String
        let language: String
        let files: [TemplateFile]
    }
    
    struct TemplateFile {
        let path: String
        let content: String
    }
    
    private static let calculatorTemplate = Template(
        name: "Calculator App",
        language: "JavaScript",
        files: [
            TemplateFile(path: "index.html", content: calculatorHTML),
            TemplateFile(path: "style.css", content: calculatorCSS),
            TemplateFile(path: "script.js", content: calculatorJS),
            TemplateFile(path: "README.md", content: "# Calculator App\n\nA modern calculator built with HTML, CSS, and JavaScript.")
        ]
    )
    
    private static let todoTemplate = Template(
        name: "Todo List App",
        language: "JavaScript",
        files: [
            TemplateFile(path: "index.html", content: todoHTML),
            TemplateFile(path: "style.css", content: todoCSS),
            TemplateFile(path: "app.js", content: todoJS),
            TemplateFile(path: "README.md", content: "# Todo List App\n\nA simple todo list application with modern design.")
        ]
    )
    
    private static let weatherTemplate = Template(
        name: "Weather App",
        language: "JavaScript",
        files: [
            TemplateFile(path: "index.html", content: weatherHTML),
            TemplateFile(path: "style.css", content: weatherCSS),
            TemplateFile(path: "weather.js", content: weatherJS),
            TemplateFile(path: "README.md", content: "# Weather App\n\nA beautiful weather application with modern UI.")
        ]
    )
    
    private static let helloAITemplate = Template(
        name: "Hello AI World",
        language: "Multi-language",
        files: [
            TemplateFile(path: "index.html", content: helloAIHTML),
            TemplateFile(path: "style.css", content: helloAICSS),
            TemplateFile(path: "script.js", content: helloAIJS),
            TemplateFile(path: "hello-ai.py", content: helloAIPython),
            TemplateFile(path: "README.md", content: "# Hello AI World\n\nA spectacular showcase of AI-powered development.")
        ]
    )
    
    private static let basicWebTemplate = Template(
        name: "Basic Web App",
        language: "JavaScript",
        files: [
            TemplateFile(path: "index.html", content: "<html><head><title>Generated App</title><link rel='stylesheet' href='style.css'></head><body><h1>Welcome to Your Generated App</h1><script src='script.js'></script></body></html>"),
            TemplateFile(path: "style.css", content: "body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; } h1 { color: #333; }"),
            TemplateFile(path: "script.js", content: "console.log('Hello from your generated app!'); document.addEventListener('DOMContentLoaded', () => { console.log('App loaded successfully!'); });"),
            TemplateFile(path: "README.md", content: "# Generated Web App\n\nThis app was generated by CodeCraft AI from your Apple Watch!")
        ]
    )
}

// Template content constants
private let calculatorHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calculator</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="calculator">
        <div class="display">
            <input type="text" id="result" readonly>
        </div>
        <div class="buttons">
            <button onclick="clearDisplay()">C</button>
            <button onclick="deleteLast()">⌫</button>
            <button onclick="appendToDisplay('/')">/</button>
            <button onclick="appendToDisplay('*')">×</button>
            <button onclick="appendToDisplay('7')">7</button>
            <button onclick="appendToDisplay('8')">8</button>
            <button onclick="appendToDisplay('9')">9</button>
            <button onclick="appendToDisplay('-')">-</button>
            <button onclick="appendToDisplay('4')">4</button>
            <button onclick="appendToDisplay('5')">5</button>
            <button onclick="appendToDisplay('6')">6</button>
            <button onclick="appendToDisplay('+')">+</button>
            <button onclick="appendToDisplay('1')">1</button>
            <button onclick="appendToDisplay('2')">2</button>
            <button onclick="appendToDisplay('3')">3</button>
            <button onclick="calculate()" class="equals">=</button>
            <button onclick="appendToDisplay('0')" class="zero">0</button>
            <button onclick="appendToDisplay('.')">.</button>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>
"""

private let calculatorCSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; justify-content: center; align-items: center; min-height: 100vh; }
.calculator { background: white; border-radius: 20px; padding: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); }
.display { margin-bottom: 20px; }
#result { width: 100%; height: 60px; font-size: 24px; text-align: right; padding: 0 15px; border: 2px solid #ddd; border-radius: 10px; background: #f9f9f9; }
.buttons { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
button { height: 60px; font-size: 18px; border: none; border-radius: 10px; cursor: pointer; background: #f0f0f0; transition: all 0.2s; }
button:hover { background: #e0e0e0; transform: translateY(-2px); }
.equals { background: #4CAF50; color: white; }
.zero { grid-column: span 2; }
"""

private let calculatorJS = """
let display = document.getElementById('result');
function appendToDisplay(value) { if (display.value === '0' && value !== '.') { display.value = value; } else { display.value += value; } }
function clearDisplay() { display.value = ''; }
function deleteLast() { display.value = display.value.slice(0, -1); }
function calculate() { try { let result = eval(display.value.replace('×', '*')); display.value = result; } catch (error) { display.value = 'Error'; } }
"""

private let todoHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Todo List</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>📝 Todo List</h1>
        <div class="input-section">
            <input type="text" id="todoInput" placeholder="Add a new task...">
            <button id="addBtn">Add</button>
        </div>
        <div id="todoList"></div>
    </div>
    <script src="app.js"></script>
</body>
</html>
"""

private let todoCSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: Arial, sans-serif; background: #f0f2f5; padding: 20px; }
.container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; padding: 30px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
h1 { text-align: center; color: #333; margin-bottom: 30px; }
.input-section { display: flex; margin-bottom: 30px; }
#todoInput { flex: 1; padding: 12px; border: 2px solid #ddd; border-radius: 5px; font-size: 16px; }
#addBtn { padding: 12px 20px; background: #007bff; color: white; border: none; border-radius: 5px; margin-left: 10px; cursor: pointer; }
.todo-item { display: flex; align-items: center; padding: 15px; border-bottom: 1px solid #eee; }
.todo-item.completed { opacity: 0.6; text-decoration: line-through; }
"""

private let todoJS = """
let todos = []; let todoId = 0;
function addTodo() { const input = document.getElementById('todoInput'); const text = input.value.trim(); if (text === '') return; todos.push({ id: todoId++, text: text, completed: false }); input.value = ''; renderTodos(); }
function toggleTodo(id) { todos = todos.map(todo => todo.id === id ? { ...todo, completed: !todo.completed } : todo); renderTodos(); }
function deleteTodo(id) { todos = todos.filter(todo => todo.id !== id); renderTodos(); }
function renderTodos() { const todoList = document.getElementById('todoList'); todoList.innerHTML = ''; todos.forEach(todo => { const todoItem = document.createElement('div'); todoItem.className = `todo-item ${todo.completed ? 'completed' : ''}`; todoItem.innerHTML = `<input type="checkbox" ${todo.completed ? 'checked' : ''} onchange="toggleTodo(${todo.id})"><span style="flex: 1; margin-left: 10px;">${todo.text}</span><button onclick="deleteTodo(${todo.id})" style="background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">Delete</button>`; todoList.appendChild(todoItem); }); }
document.getElementById('addBtn').addEventListener('click', addTodo);
document.getElementById('todoInput').addEventListener('keypress', function(e) { if (e.key === 'Enter') addTodo(); });
"""

private let weatherHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather App</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="weather-container">
        <h1>🌤️ Weather App</h1>
        <div class="search">
            <input type="text" id="cityInput" placeholder="Enter city name...">
            <button onclick="getWeather()">Search</button>
        </div>
        <div id="weatherInfo" class="weather-info">
            <div class="temperature" id="temperature">22°C</div>
            <div class="description" id="description">Sunny in Demo City</div>
            <div class="details">
                <div class="detail"><div>Humidity</div><div id="humidity">65%</div></div>
                <div class="detail"><div>Wind</div><div id="wind">12 km/h</div></div>
            </div>
        </div>
    </div>
    <script src="weather.js"></script>
</body>
</html>
"""

private let weatherCSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #74b9ff, #0984e3); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
.weather-container { background: rgba(255,255,255,0.9); border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
h1 { color: #333; margin-bottom: 30px; }
.search { margin-bottom: 30px; }
input { padding: 12px; border: 2px solid #ddd; border-radius: 25px; width: 250px; font-size: 16px; }
button { padding: 12px 20px; background: #0984e3; color: white; border: none; border-radius: 25px; margin-left: 10px; cursor: pointer; }
.temperature { font-size: 48px; font-weight: bold; color: #333; }
.description { font-size: 18px; color: #666; margin: 10px 0; }
.details { display: flex; justify-content: space-around; margin-top: 20px; }
"""

private let weatherJS = """
const demoData = { 'london': { temp: 18, desc: 'Cloudy', humidity: 65, wind: 12 }, 'paris': { temp: 22, desc: 'Sunny', humidity: 45, wind: 8 }, 'tokyo': { temp: 25, desc: 'Partly Cloudy', humidity: 70, wind: 15 } };
function getWeather() { const city = document.getElementById('cityInput').value.toLowerCase().trim(); if (!city) { alert('Please enter a city name'); return; } const data = demoData[city] || { temp: Math.floor(Math.random() * 30) + 5, desc: ['Sunny', 'Cloudy', 'Rainy'][Math.floor(Math.random() * 3)], humidity: Math.floor(Math.random() * 40) + 40, wind: Math.floor(Math.random() * 20) + 5 }; document.getElementById('temperature').textContent = `${data.temp}°C`; document.getElementById('description').textContent = `${data.desc} in ${city.charAt(0).toUpperCase() + city.slice(1)}`; document.getElementById('humidity').textContent = `${data.humidity}%`; document.getElementById('wind').textContent = `${data.wind} km/h`; }
document.getElementById('cityInput').addEventListener('keypress', function(e) { if (e.key === 'Enter') getWeather(); });
"""

private let helloAIHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello AI World</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>🤖 Hello AI World!</h1>
        <p class="subtitle">Welcome to the future of development</p>
        <div class="features">
            <div class="feature">
                <h3>🎤 Voice-Powered</h3>
                <p>Created from Apple Watch voice commands</p>
            </div>
            <div class="feature">
                <h3>🧠 AI-Generated</h3>
                <p>Built by advanced AI technology</p>
            </div>
            <div class="feature">
                <h3>⚡ Instant Deploy</h3>
                <p>From idea to code in seconds</p>
            </div>
        </div>
        <button onclick="showMessage()">Experience AI Magic</button>
        <div id="message" class="message"></div>
    </div>
    <script src="script.js"></script>
</body>
</html>
"""

private let helloAICSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Arial', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
.container { background: rgba(255,255,255,0.95); border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 20px 40px rgba(0,0,0,0.1); max-width: 600px; }
h1 { font-size: 2.5em; margin-bottom: 10px; background: linear-gradient(45deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
.subtitle { font-size: 1.2em; color: #666; margin-bottom: 30px; }
.features { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 20px; margin: 30px 0; }
.feature { padding: 20px; background: #f8f9fa; border-radius: 10px; }
.feature h3 { margin-bottom: 10px; color: #333; }
button { background: linear-gradient(45deg, #667eea, #764ba2); color: white; border: none; padding: 15px 30px; border-radius: 25px; font-size: 16px; cursor: pointer; margin: 20px 0; }
.message { margin-top: 20px; padding: 20px; background: #e8f5e8; border-radius: 10px; display: none; }
"""

private let helloAIJS = """
const messages = ['🎉 Welcome to the AI revolution!', '🚀 Your ideas, instantly realized!', '✨ The future of development is here!', '🤖 AI-powered creativity unleashed!'];
function showMessage() { const messageDiv = document.getElementById('message'); const randomMessage = messages[Math.floor(Math.random() * messages.length)]; messageDiv.textContent = randomMessage; messageDiv.style.display = 'block'; setTimeout(() => { messageDiv.style.display = 'none'; }, 3000); }
"""

private let helloAIPython = """
#!/usr/bin/env python3
\"\"\"
Hello AI World - Python Edition
Generated by CodeCraft AI from Apple Watch
\"\"\"

import random
import time

def main():
    print("🤖 Hello AI World!")
    print("=" * 40)
    print("Welcome to the future of development!")
    print("This code was generated by AI from your Apple Watch!")
    
    ai_facts = [
        "AI can now generate complete applications",
        "Voice-to-code is the future of programming",
        "Apple Watch development is revolutionary",
        "CodeCraft AI makes coding accessible to everyone"
    ]
    
    print("\\n✨ AI Fact of the moment:")
    print(f"   {random.choice(ai_facts)}")
    
    print("\\n🚀 Generating some AI magic...")
    for i in range(3):
        time.sleep(0.5)
        print(f"   {'.' * (i + 1)} Processing")
    
    print("\\n🎉 AI magic complete!")
    print("The future is now! 🌟")

if __name__ == "__main__":
    main()
"""

// MARK: - Mock Repository and Models
struct Repository {
    let name: String
}

struct FileChange: Codable, Identifiable {
    let id = UUID()
    let path: String
    let content: String
    let operation: FileOperation
    let diff: String?
    
    enum CodingKeys: String, CodingKey {
        case path, content, operation, diff
    }
}

enum FileOperation: String, Codable {
    case create = "create"
    case update = "update"
    case delete = "delete"
}

struct CodeGenerationResponse: Codable {
    let files: [FileChange]
    let commitMessage: String
    let summary: String
    let branchName: String?
}

// MARK: - LLM Service
class LLMService: ObservableObject {
    static let shared = LLMService()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - Main Code Generation
    func processVoiceRequest(_ transcription: String, repository: Repository) async throws -> CodeGenerationResponse {
        if APICredentials.verboseLogging {
            print("🎤 Processing voice request: \(transcription)")
        }
        
        // Check if we should use demo mode or templates
        if APICredentials.demoMode {
            return try await generateFromTemplate(transcription)
        }
        
        // Try Claude API first, fallback to templates
        do {
            return try await generateWithClaude(transcription)
        } catch {
            if APICredentials.verboseLogging {
                print("⚠️ Claude API failed: \(error.localizedDescription)")
                print("🔄 Falling back to templates...")
            }
            
            if APICredentials.useLocalTemplates {
                return try await generateFromTemplate(transcription)
            } else {
                throw error
            }
        }
    }
    
    // MARK: - Claude API Integration
    private func generateWithClaude(_ request: String) async throws -> CodeGenerationResponse {
        if APICredentials.verboseLogging {
            print("🤖 Calling Claude API...")
        }
        
        // Get API key from secure storage or config
        guard let apiKey = APICredentials.activeClaudeAPIKey else {
            throw LLMError.invalidCredentials("Please set your Claude API key in settings")
        }
        
        let prompt = createClaudePrompt(for: request)
        let response = try await callClaudeAPI(prompt: prompt, apiKey: apiKey)
        
        return try await parseClaudeResponse(response, originalRequest: request)
    }
    
    private func callClaudeAPI(prompt: String, apiKey: String) async throws -> String {
        let url = URL(string: APIEndpoints.claudeBaseURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = APIEndpoints.claudeHeaders(apiKey: apiKey)
        request.timeoutInterval = APIEndpoints.RequestConfig.timeoutInterval
        
        let requestBody: [String: Any] = [
            "model": APIEndpoints.ClaudeConfig.model,
            "max_tokens": APIEndpoints.ClaudeConfig.maxTokens,
            "temperature": APIEndpoints.ClaudeConfig.temperature,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        if APICredentials.simulateDelay {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.networkError("Invalid response")
        }
        
        if APICredentials.verboseLogging {
            print("📡 Claude API Response Status: \(httpResponse.statusCode)")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw LLMError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse Claude response
        let claudeResponse = try decoder.decode(ClaudeResponse.self, from: data)
        return claudeResponse.content.first?.text ?? ""
    }
    
    // MARK: - Template-based Generation
    private func generateFromTemplate(_ request: String) async throws -> CodeGenerationResponse {
        if APICredentials.verboseLogging {
            print("📋 Using template for request: \(request)")
        }
        
        if APICredentials.simulateDelay {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
        guard let template = CodeTemplates.findTemplate(for: request) else {
            throw LLMError.templateNotFound("No template found for request: \(request)")
        }
        
        let files = template.files.map { templateFile in
            FileChange(
                path: templateFile.path,
                content: templateFile.content,
                operation: .create,
                diff: nil
            )
        }
        
        return CodeGenerationResponse(
            files: files,
            commitMessage: "Create \(template.name) via voice command",
            summary: "Generated \(template.name) (\(template.language)) with \(files.count) files",
            branchName: nil
        )
    }
    
    // MARK: - Claude Prompt Engineering
    private func createClaudePrompt(for request: String) -> String {
        return """
        You are CodeCraft AI, a master software architect and senior developer with decades of experience across all major programming languages, frameworks, and industry best practices.

        Human: \(request)

        Please create a complete, production-ready software project based on this request. 

        REQUIREMENTS:
        1. Generate MULTIPLE interconnected files (minimum 4-6 files)
        2. Use modern development practices and clean architecture
        3. Include comprehensive documentation and comments
        4. Create a detailed README.md with setup instructions
        5. Ensure all files work together as a cohesive application

        TECHNICAL STANDARDS:
        - Use semantic HTML5 for web applications
        - Implement responsive CSS with modern techniques
        - Write clean JavaScript with ES6+ features
        - Follow consistent naming conventions
        - Include proper error handling and validation
        - Add accessibility features where applicable

        OUTPUT FORMAT:
        Please provide each file in the following format:

        **filename.ext**
        ```language
        [complete file content here]
        ```

        Generate a complete, functional project now:
        """
    }
    
    // MARK: - Response Parsing
    private func parseClaudeResponse(_ response: String, originalRequest: String) async throws -> CodeGenerationResponse {
        if APICredentials.verboseLogging {
            print("🔍 Parsing Claude response...")
        }
        
        // Extract code files from Claude's response
        let files = extractCodeFilesFromClaude(response)
        
        if files.isEmpty {
            // Fallback to template if Claude didn't generate proper code
            if APICredentials.verboseLogging {
                print("⚠️ No code files found in Claude response, using template fallback")
            }
            return try await generateFromTemplate(originalRequest)
        }
        
        return CodeGenerationResponse(
            files: files,
            commitMessage: "Generate code via Claude AI: \(originalRequest)",
            summary: "Generated \(files.count) files using Claude AI from voice command",
            branchName: nil
        )
    }
    
    private func extractCodeFilesFromClaude(_ response: String) -> [FileChange] {
        var files: [FileChange] = []
        
        // Look for Claude's file format: **filename.ext** followed by code block
        let filePattern = #"\*\*([^*]+)\*\*\s*```(\w+)?\s*(.*?)```"#
        let regex = try! NSRegularExpression(pattern: filePattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: response, range: NSRange(response.startIndex..., in: response))
        
        for match in matches {
            if match.numberOfRanges >= 4 {
                let filenameRange = match.range(at: 1)
                let codeRange = match.range(at: 3)
                
                let filename = String(response[Range(filenameRange, in: response)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                let code = String(response[Range(codeRange, in: response)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                files.append(FileChange(
                    path: filename,
                    content: code,
                    operation: .create,
                    diff: nil
                ))
            }
        }
        
        // Fallback: look for standard code blocks if no files found
        if files.isEmpty {
            let codeBlockPattern = #"```(\w+)?\n(.*?)\n```"#
            let codeRegex = try! NSRegularExpression(pattern: codeBlockPattern, options: [.dotMatchesLineSeparators])
            let codeMatches = codeRegex.matches(in: response, range: NSRange(response.startIndex..., in: response))
            
            for (index, match) in codeMatches.enumerated() {
                if match.numberOfRanges >= 3 {
                    let languageRange = match.range(at: 1)
                    let codeRange = match.range(at: 2)
                    
                    let language = languageRange.location != NSNotFound ? 
                        String(response[Range(languageRange, in: response)!]) : "txt"
                    let code = String(response[Range(codeRange, in: response)!]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let filename = generateFilename(for: language, index: index)
                    files.append(FileChange(
                        path: filename,
                        content: code,
                        operation: .create,
                        diff: nil
                    ))
                }
            }
        }
        
        return files
    }
    
    private func generateFilename(for language: String, index: Int) -> String {
        let extensions: [String: String] = [
            "html": "html",
            "css": "css",
            "javascript": "js",
            "js": "js",
            "python": "py",
            "swift": "swift",
            "java": "java",
            "cpp": "cpp",
            "c": "c"
        ]
        
        let ext = extensions[language.lowercased()] ?? "txt"
        return index == 0 ? "main.\(ext)" : "file\(index + 1).\(ext)"
    }
}

// MARK: - Error Types
enum LLMError: Error, LocalizedError {
    case invalidCredentials(String)
    case networkError(String)
    case apiError(String)
    case templateNotFound(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials(let message):
            return "Invalid credentials: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .templateNotFound(let message):
            return "Template not found: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}
