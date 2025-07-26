//
//  CodeTemplates.swift
//  codietalkie
//
//  Pre-built code templates for common requests
//  Used as fallback when LLM API is unavailable
//

import Foundation

struct CodeTemplates {
    
    // MARK: - Template Structure
    struct Template {
        let name: String
        let description: String
        let files: [TemplateFile]
        let language: String
        let framework: String?
    }
    
    struct TemplateFile {
        let name: String
        let content: String
        let path: String
    }
    
    // MARK: - Available Templates
    static let allTemplates: [String: Template] = [
        "calculator": calculatorTemplate,
        "todo": todoListTemplate,
        "weather": weatherAppTemplate,
        "timer": timerTemplate
    ]
    
    // MARK: - Calculator Template
    static let calculatorTemplate = Template(
        name: "Basic Calculator",
        description: "A simple calculator with basic arithmetic operations",
        files: [
            TemplateFile(
                name: "index.html",
                content: calculatorHTML,
                path: "index.html"
            ),
            TemplateFile(
                name: "style.css",
                content: calculatorCSS,
                path: "style.css"
            ),
            TemplateFile(
                name: "script.js",
                content: calculatorJS,
                path: "script.js"
            ),
            TemplateFile(
                name: "README.md",
                content: calculatorReadme,
                path: "README.md"
            )
        ],
        language: "JavaScript",
        framework: "HTML/CSS/JS"
    )
    
    // MARK: - Todo List Template
    static let todoListTemplate = Template(
        name: "Todo List App",
        description: "A simple todo list application",
        files: [
            TemplateFile(
                name: "index.html",
                content: todoHTML,
                path: "index.html"
            ),
            TemplateFile(
                name: "app.js",
                content: todoJS,
                path: "app.js"
            ),
            TemplateFile(
                name: "README.md",
                content: todoReadme,
                path: "README.md"
            )
        ],
        language: "JavaScript",
        framework: "HTML/CSS/JS"
    )
    
    // MARK: - Weather App Template
    static let weatherAppTemplate = Template(
        name: "Weather App",
        description: "A simple weather application",
        files: [
            TemplateFile(
                name: "index.html",
                content: weatherHTML,
                path: "index.html"
            ),
            TemplateFile(
                name: "weather.js",
                content: weatherJS,
                path: "weather.js"
            ),
            TemplateFile(
                name: "README.md",
                content: weatherReadme,
                path: "README.md"
            )
        ],
        language: "JavaScript",
        framework: "HTML/CSS/JS"
    )
    
    // MARK: - Timer Template
    static let timerTemplate = Template(
        name: "Timer App",
        description: "A simple countdown timer",
        files: [
            TemplateFile(
                name: "index.html",
                content: timerHTML,
                path: "index.html"
            ),
            TemplateFile(
                name: "timer.js",
                content: timerJS,
                path: "timer.js"
            ),
            TemplateFile(
                name: "README.md",
                content: timerReadme,
                path: "README.md"
            )
        ],
        language: "JavaScript",
        framework: "HTML/CSS/JS"
    )
}

// MARK: - Template Matching
extension CodeTemplates {
    static func findTemplate(for request: String) -> Template? {
        let lowercased = request.lowercased()
        
        if lowercased.contains("calculator") || lowercased.contains("calc") {
            return calculatorTemplate
        } else if lowercased.contains("todo") || lowercased.contains("task") {
            return todoListTemplate
        } else if lowercased.contains("weather") {
            return weatherAppTemplate
        } else if lowercased.contains("timer") || lowercased.contains("countdown") {
            return timerTemplate
        }
        
        // Default to calculator for demo
        return calculatorTemplate
    }
}

// MARK: - Calculator Template Content
private let calculatorHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Basic Calculator</title>
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
            <button onclick="calculate()" rowspan="2">=</button>
            
            <button onclick="appendToDisplay('0')" colspan="2">0</button>
            <button onclick="appendToDisplay('.')">.</button>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>
"""

private let calculatorCSS = """
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
}

.calculator {
    background: white;
    border-radius: 20px;
    padding: 20px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    max-width: 300px;
}

.display {
    margin-bottom: 20px;
}

#result {
    width: 100%;
    height: 60px;
    font-size: 24px;
    text-align: right;
    padding: 0 15px;
    border: 2px solid #ddd;
    border-radius: 10px;
    background: #f9f9f9;
}

.buttons {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
}

button {
    height: 60px;
    font-size: 18px;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    background: #f0f0f0;
}

button:hover {
    background: #e0e0e0;
    transform: translateY(-2px);
}

button:active {
    transform: translateY(0);
}
"""

private let calculatorJS = """
let display = document.getElementById('result');
let currentInput = '';
let operator = '';
let previousInput = '';

function appendToDisplay(value) {
    if (display.value === '0' && value !== '.') {
        display.value = value;
    } else {
        display.value += value;
    }
}

function clearDisplay() {
    display.value = '';
    currentInput = '';
    operator = '';
    previousInput = '';
}

function deleteLast() {
    display.value = display.value.slice(0, -1);
}

function calculate() {
    try {
        let result = eval(display.value.replace('×', '*'));
        display.value = result;
    } catch (error) {
        display.value = 'Error';
    }
}

// Keyboard support
document.addEventListener('keydown', function(event) {
    const key = event.key;
    
    if (key >= '0' && key <= '9' || key === '.') {
        appendToDisplay(key);
    } else if (key === '+' || key === '-' || key === '*' || key === '/') {
        appendToDisplay(key === '*' ? '×' : key);
    } else if (key === 'Enter' || key === '=') {
        calculate();
    } else if (key === 'Escape' || key === 'c' || key === 'C') {
        clearDisplay();
    } else if (key === 'Backspace') {
        deleteLast();
    }
});
"""

private let calculatorReadme = """
# Basic Calculator

A simple, responsive calculator built with HTML, CSS, and JavaScript.

## Features

- Basic arithmetic operations (+, -, ×, ÷)
- Clear and delete functions
- Keyboard support
- Responsive design
- Modern UI with hover effects

## Usage

1. Open `index.html` in your web browser
2. Click buttons or use keyboard to input numbers and operations
3. Press '=' or Enter to calculate
4. Press 'C' or Escape to clear

## Keyboard Shortcuts

- Numbers (0-9): Input numbers
- +, -, *, /: Operations
- Enter or =: Calculate
- Escape or C: Clear
- Backspace: Delete last character

## Files

- `index.html`: Main HTML structure
- `style.css`: Styling and layout
- `script.js`: Calculator functionality

Created with ❤️ by codietalkie
"""

// MARK: - Todo List Template Content
private let todoHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Todo List</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f0f2f5; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; padding: 30px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        h1 { text-align: center; color: #333; margin-bottom: 30px; }
        .input-section { display: flex; margin-bottom: 30px; }
        #todoInput { flex: 1; padding: 12px; border: 2px solid #ddd; border-radius: 5px; font-size: 16px; }
        #addBtn { padding: 12px 20px; background: #007bff; color: white; border: none; border-radius: 5px; margin-left: 10px; cursor: pointer; }
        .todo-item { display: flex; align-items: center; padding: 15px; border-bottom: 1px solid #eee; }
        .todo-item.completed { opacity: 0.6; text-decoration: line-through; }
        .todo-text { flex: 1; margin-left: 10px; }
        .delete-btn { background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; }
    </style>
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

private let todoJS = """
let todos = [];
let todoId = 0;

function addTodo() {
    const input = document.getElementById('todoInput');
    const text = input.value.trim();
    
    if (text === '') return;
    
    todos.push({
        id: todoId++,
        text: text,
        completed: false
    });
    
    input.value = '';
    renderTodos();
}

function toggleTodo(id) {
    todos = todos.map(todo => 
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
    );
    renderTodos();
}

function deleteTodo(id) {
    todos = todos.filter(todo => todo.id !== id);
    renderTodos();
}

function renderTodos() {
    const todoList = document.getElementById('todoList');
    todoList.innerHTML = '';
    
    todos.forEach(todo => {
        const todoItem = document.createElement('div');
        todoItem.className = `todo-item ${todo.completed ? 'completed' : ''}`;
        
        todoItem.innerHTML = `
            <input type="checkbox" ${todo.completed ? 'checked' : ''} 
                   onchange="toggleTodo(${todo.id})">
            <span class="todo-text">${todo.text}</span>
            <button class="delete-btn" onclick="deleteTodo(${todo.id})">Delete</button>
        `;
        
        todoList.appendChild(todoItem);
    });
}

document.getElementById('addBtn').addEventListener('click', addTodo);
document.getElementById('todoInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') addTodo();
});
"""

private let todoReadme = """
# Todo List App

A simple todo list application built with HTML, CSS, and JavaScript.

## Features

- Add new tasks
- Mark tasks as completed
- Delete tasks
- Responsive design
- Local storage (can be added)

## Usage

1. Open `index.html` in your web browser
2. Type a task in the input field
3. Click "Add" or press Enter
4. Check tasks to mark as completed
5. Click "Delete" to remove tasks

Created with ❤️ by codietalkie
"""

// MARK: - Weather App Template Content
private let weatherHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #74b9ff, #0984e3); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .weather-container { background: rgba(255,255,255,0.9); border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        h1 { color: #333; margin-bottom: 30px; }
        .search { margin-bottom: 30px; }
        input { padding: 12px; border: 2px solid #ddd; border-radius: 25px; width: 250px; font-size: 16px; }
        button { padding: 12px 20px; background: #0984e3; color: white; border: none; border-radius: 25px; margin-left: 10px; cursor: pointer; }
        .weather-info { margin-top: 30px; }
        .temperature { font-size: 48px; font-weight: bold; color: #333; }
        .description { font-size: 18px; color: #666; margin: 10px 0; }
        .details { display: flex; justify-content: space-around; margin-top: 20px; }
        .detail { text-align: center; }
    </style>
</head>
<body>
    <div class="weather-container">
        <h1>🌤️ Weather App</h1>
        <div class="search">
            <input type="text" id="cityInput" placeholder="Enter city name...">
            <button onclick="getWeather()">Search</button>
        </div>
        <div id="weatherInfo" class="weather-info" style="display: none;">
            <div class="temperature" id="temperature">--°</div>
            <div class="description" id="description">--</div>
            <div class="details">
                <div class="detail">
                    <div>Humidity</div>
                    <div id="humidity">--%</div>
                </div>
                <div class="detail">
                    <div>Wind</div>
                    <div id="wind">-- km/h</div>
                </div>
            </div>
        </div>
    </div>
    <script src="weather.js"></script>
</body>
</html>
"""

private let weatherJS = """
// Demo weather data (replace with real API)
const demoWeatherData = {
    'london': { temp: 18, desc: 'Cloudy', humidity: 65, wind: 12 },
    'paris': { temp: 22, desc: 'Sunny', humidity: 45, wind: 8 },
    'tokyo': { temp: 25, desc: 'Partly Cloudy', humidity: 70, wind: 15 },
    'new york': { temp: 20, desc: 'Rainy', humidity: 80, wind: 18 }
};

function getWeather() {
    const city = document.getElementById('cityInput').value.toLowerCase().trim();
    
    if (!city) {
        alert('Please enter a city name');
        return;
    }
    
    // Simulate API call delay
    setTimeout(() => {
        const weatherData = demoWeatherData[city] || {
            temp: Math.floor(Math.random() * 30) + 5,
            desc: ['Sunny', 'Cloudy', 'Rainy', 'Partly Cloudy'][Math.floor(Math.random() * 4)],
            humidity: Math.floor(Math.random() * 40) + 40,
            wind: Math.floor(Math.random() * 20) + 5
        };
        
        displayWeather(weatherData, city);
    }, 500);
}

function displayWeather(data, city) {
    document.getElementById('temperature').textContent = `${data.temp}°C`;
    document.getElementById('description').textContent = `${data.desc} in ${city.charAt(0).toUpperCase() + city.slice(1)}`;
    document.getElementById('humidity').textContent = `${data.humidity}%`;
    document.getElementById('wind').textContent = `${data.wind} km/h`;
    
    document.getElementById('weatherInfo').style.display = 'block';
}

document.getElementById('cityInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') getWeather();
});
"""

private let weatherReadme = """
# Weather App

A simple weather application with demo data.

## Features

- City weather search
- Temperature display
- Weather description
- Humidity and wind information
- Responsive design

## Usage

1. Open `index.html` in your web browser
2. Enter a city name
3. Click "Search" or press Enter
4. View weather information

## Note

This is a demo version with sample data. To use real weather data, integrate with a weather API like OpenWeatherMap.

Created with ❤️ by codietalkie
"""

// MARK: - Timer Template Content
private let timerHTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Timer App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea, #764ba2); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .timer-container { background: white; border-radius: 20px; padding: 50px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.3); }
        h1 { color: #333; margin-bottom: 40px; }
        .timer-display { font-size: 72px; font-weight: bold; color: #667eea; margin: 30px 0; font-family: 'Courier New', monospace; }
        .controls { margin: 30px 0; }
        .time-inputs { margin-bottom: 20px; }
        .time-inputs input { width: 60px; padding: 10px; margin: 0 5px; text-align: center; border: 2px solid #ddd; border-radius: 5px; font-size: 18px; }
        .buttons button { padding: 15px 25px; margin: 0 10px; border: none; border-radius: 25px; font-size: 16px; cursor: pointer; transition: all 0.3s; }
        .start-btn { background: #28a745; color: white; }
        .pause-btn { background: #ffc107; color: black; }
        .reset-btn { background: #dc3545; color: white; }
        button:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.2); }
    </style>
</head>
<body>
    <div class="timer-container">
        <h1>⏰ Timer App</h1>
        <div class="time-inputs">
            <input type="number" id="hours" min="0" max="23" value="0" placeholder="HH">
            <span>:</span>
            <input type="number" id="minutes" min="0" max="59" value="5" placeholder="MM">
            <span>:</span>
            <input type="number" id="seconds" min="0" max="59" value="0" placeholder="SS">
        </div>
        <div class="timer-display" id="timerDisplay">05:00</div>
        <div class="buttons">
            <button class="start-btn" onclick="startTimer()">Start</button>
            <button class="pause-btn" onclick="pauseTimer()">Pause</button>
            <button class="reset-btn" onclick="resetTimer()">Reset</button>
        </div>
    </div>
    <script src="timer.js"></script>
</body>
</html>
"""

private let timerJS = """
let timerInterval;
let totalSeconds = 0;
let isRunning = false;

function updateDisplay() {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    
    const display = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    document.getElementById('timerDisplay').textContent = display;
}

function startTimer() {
    if (!isRunning) {
        if (totalSeconds === 0) {
            const hours = parseInt(document.getElementById('hours').value) || 0;
            const minutes = parseInt(document.getElementById('minutes').value) || 0;
            const seconds = parseInt(document.getElementById('seconds').value) || 0;
            totalSeconds = hours * 3600 + minutes * 60 + seconds;
        }
        
        if (totalSeconds > 0) {
            isRunning = true;
            timerInterval = setInterval(() => {
                totalSeconds--;
                updateDisplay();
                
                if (totalSeconds <= 0) {
                    clearInterval(timerInterval);
                    isRunning = false;
                    alert('Time\'s up! ⏰');
                }
            }, 1000);
        }
    }
}

function pauseTimer() {
    if (isRunning) {
        clearInterval(timerInterval);
        isRunning = false;
    }
}

function resetTimer() {
    clearInterval(timerInterval);
    isRunning = false;
    totalSeconds = 0;
    updateDisplay();
}

// Initialize display
updateDisplay();
"""

private let timerReadme = """
# Timer App

A simple countdown timer application.

## Features

- Set custom hours, minutes, and seconds
- Start, pause, and reset functionality
- Visual countdown display
- Alert when timer reaches zero
- Clean, modern interface

## Usage

1. Open `index.html` in your web browser
2. Set desired time using the input fields
3. Click "Start" to begin countdown
4. Use "Pause" to pause and "Reset" to reset

## Controls

- **Start**: Begin the countdown
- **Pause**: Pause the current timer
- **Reset**: Reset timer to 00:00:00

Created with ❤️ by codietalkie
"""
