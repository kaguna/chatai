require "ollama-ai"

class AiService
  OLLAMA_ADDRESS = "http://localhost:11434"
  DEFAULT_MODEL = "llama3:latest"

  attr_reader :conversation, :model, :client

  def initialize(conversation, model = DEFAULT_MODEL)
    @conversation = conversation
    @model = model
    @client ||= Ollama.new(
      credentials: { address: OLLAMA_ADDRESS },
      options: { server_sent_events: true, model: model }
    )
  end

  def chat(user_message, model, &block)
    # Get conversation history for context
    messages = build_conversation_context

    # Add the current user message to the context
    messages << { role: "user", content: user_message }

    # Generate AI response with streaming
    generate_response(messages, model, &block)
  end

  def models
    @client.tags.first["models"].map do |model|
      {
        name: model["name"],
        model: model["model"],
        parameters: model["details"]["parameter_size"]
      }
    end
  end

  private

  def build_conversation_context
    # Get all messages in chronological order
    messages = @conversation.messages.order(created_at: :asc)

    # Convert to format expected by Ollama
    context_messages = messages.map do |message|
      {
        role: message.role,
        content: message.content
      }
    end

    # Add system message if this is the first user message
    if messages.where(role: "user").count == 1
      context_messages.unshift({
        role: "system",
        content: "You are a helpful AI assistant. Provide clear, concise, and helpful responses."
      })
    end

    context_messages
  end

  def generate_response(messages, model, &block)
    full_response = ""
    chunks = []

    begin
      # Use the correct Ollama API format
      @client.generate({
        model: model,
        prompt: build_prompt_from_messages(messages),
        stream: true,
        options: {
          temperature: 0.7,
          top_p: 0.9,
          num_predict: 1000
        }
      }) do |event, raw|
        if event["response"]
          chunk = event["response"]
          Rails.logger.info "Event: #{chunk}"
          chunks << chunk
          full_response += chunk

          # Yield the chunk if a block is provided
          yield(chunk) if block_given?
        end
      end

      # Ensure we have a response
      if full_response.blank?
        full_response = "I apologize, but I couldn't generate a response. Please try again."
      end

      full_response

    rescue => e
      Rails.logger.error "Error generating AI response: #{e.message}"

      "I apologize, but I encountered an error while processing your request. Please try again."
    end
  end

  def build_prompt_from_messages(messages)
    # Convert messages to a single prompt string
    prompt_parts = []

    messages.each do |message|
      case message[:role]
      when "system"
        prompt_parts << "System: #{message[:content]}"
      when "user"
        prompt_parts << "Human: #{message[:content]}"
      when "assistant"
        prompt_parts << "Assistant: #{message[:content]}"
      end
    end

    # Add the final prompt instruction
    prompt_parts << "Assistant:"

    prompt_parts.join("\n\n")
  end
end
