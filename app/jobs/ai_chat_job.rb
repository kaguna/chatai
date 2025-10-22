class AiChatJob < ApplicationJob
  queue_as :default

  def perform(prompt, conversation_id = nil, model = "llama3:latest")
    conversation = Conversation.find_or_create_by(id: conversation_id) do |conv|
      conv.title = prompt
    end


    # Create a streaming assistant message placeholder
    assistant_message = conversation.messages.create!(
      session_id: conversation.session_id,
      role: "assistant",
      content: "Generating response..."
    )

    # Broadcast the initial streaming message
    Rails.logger.info "Broadcasting initial message to conversation_#{conversation.id}"
    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation.id}",
      target: "messages",
      partial: "messages/streaming_message",
      locals: { message: assistant_message }
    )

    # Generate AI response with streaming
    ai_service = AiService.new(conversation)
    first_chunk = true
    ai_service.chat(prompt, model) do |chunk|
      # Replace initial content with first chunk, then append subsequent chunks
      if first_chunk
        assistant_message.update!(content: chunk)
        first_chunk = false
      else
        assistant_message.update!(content: assistant_message.content + chunk)
      end

      # Broadcast the update
      Rails.logger.info "Broadcasting chunk update to conversation_#{conversation.id}"
      Turbo::StreamsChannel.broadcast_update_to(
        "conversation_#{conversation.id}",
        target: "message_#{assistant_message.id}_content",
        partial: "messages/streaming_content",
        locals: { message: assistant_message }
      )
    end

    # Update conversation title if it's the first message
    if conversation.messages.where(role: "user").count == 1
      update_conversation_title(conversation, prompt)
    end

    conversation
  end

  private

  def update_conversation_title(conversation, first_message)
    # Generate a title from the first message (truncated)
    title = first_message.truncate(50, omission: "...")
    conversation.update!(title: title)
  end

  def broadcast_streaming_message(conversation, message)
    # Broadcast the initial streaming message
    Rails.logger.info "Broadcasting initial streaming message #{message.id} to conversation_#{conversation.id}"
    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation.id}",
      target: "messages",
      partial: "messages/streaming_message",
      locals: { message: message }
    )
  end

  def broadcast_chunk_update(conversation, message, chunk)
    # Broadcast chunk update to the streaming message
    Rails.logger.info "Broadcasting chunk update for message #{message.id}: #{chunk}"
    Turbo::StreamsChannel.broadcast_update_to(
      "conversation_#{conversation.id}",
      target: "message_#{message.id}_content",
      partial: "messages/streaming_content",
      locals: { message: message }
    )
  end

  def broadcast_final_message(conversation, message)
    # Replace the streaming message with the final complete message
    Turbo::StreamsChannel.broadcast_replace_to(
      "conversation_#{conversation.id}",
      target: "message_#{message.id}",
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def broadcast_assistant_message(conversation, message)
    # Broadcast the assistant message via Turbo Stream
    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message }
    )
  end
end
