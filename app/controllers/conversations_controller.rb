class ConversationsController < ApplicationController
  # Create a new conversation
  def create_conversation
    conversation = Conversation.create!(title: "New Chat")

    redirect_to root_path(session: conversation.session_id)
  end

  # Send a message to a conversation
  def send_message
    @conversation = Conversation.find(params[:conversation_id])
    user_message = params[:message]

    # Create user message
    @user_message = @conversation.messages.create!(
      session_id: @conversation.session_id,
      role: "user",
      content: user_message
    )

    # Enqueue the chat job
    AiChatJob.perform_later(user_message, @conversation.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @user_message })
      end
      format.html { redirect_to @conversation }
    end
  end

  # Get conversation messages
  def get_messages
    conversation = Conversation.find(params[:conversation_id])
    messages = conversation.messages.order(created_at: :asc)

    redirect_to root_path(messages: messages)
  end

  # Get all conversations
  def index
    conversations = Conversation.includes(:messages).order(created_at: :desc)

    redirect_to root_path(conversations: conversations)
  end

  # Delete a conversation and all its messages
  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("conversation_#{@conversation.id}")
      end
      format.html { redirect_to root_path }
    end
  end
end
