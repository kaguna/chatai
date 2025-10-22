# ChatAI - Rails Chat Application with Ollama

A modern Rails chat application powered by Ollama AI for local AI conversations.

## Prerequisites

* Ruby 3.3+
* PostgreSQL
* Ollama (for AI functionality)

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Setup environment variables:**
   ```bash
   cp env.example .env
   ```
   Edit `.env` with your configuration values.

3. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Install and start Ollama:**
   ```bash
   # Install Ollama (visit https://ollama.ai for installation instructions)
   ollama pull llama3:latest
   ```

5. **Start the application:**
   ```bash
   bin/dev
   ```

## Environment Variables

The application uses the following environment variables (see `env.example` for details):

### Required
- `OLLAMA_ADDRESS`: Ollama server address (default: http://localhost:11434)
- `OLLAMA_MODEL`: AI model to use (default: llama3:latest)

### Optional
- `AI_TEMPERATURE`: AI response creativity (0.0-1.0, default: 0.7)
- `AI_TOP_P`: AI response diversity (0.0-1.0, default: 0.9)
- `AI_MAX_TOKENS`: Maximum response length (default: 1000)
- `RAILS_LOG_LEVEL`: Logging level (default: info)

## Features

* Real-time chat with AI using Turbo Streams
* Conversation history
* Streaming AI responses
* Mobile-responsive design
* PWA support

## Development

* Ruby version: 3.3+
* System dependencies: PostgreSQL, Ollama
* Configuration: Environment variables in `.env`
* Database creation: `rails db:create`
* Database initialization: `rails db:migrate`
* How to run the test suite: `rails test`
* Services: Ollama for AI, PostgreSQL for data
* Deployment: Kamal (see `config/deploy.yml`)
