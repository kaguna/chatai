class HomeController < ApplicationController
  def index
    @conversations = Conversation.includes(:messages).order(created_at: :desc)
    @selected_conversation = Conversation.find(params[:conversation_id]) if params[:conversation_id]
    @messages = @selected_conversation&.messages&.order(created_at: :asc) || []
    @available_models = get_available_models
  end

  def create_conversation
    @conversation = Conversation.create!(title: "New Chat")
    redirect_to root_path(conversation_id: @conversation.id)
  end

  private

  def get_available_models
    begin
      # Create a temporary AiService instance to get models
      temp_conversation = Conversation.new
      ai_service = AiService.new(temp_conversation)
      ai_service.models
    rescue => e
      Rails.logger.error "Error fetching models: #{e.message}"
      []
    end
  end
end
