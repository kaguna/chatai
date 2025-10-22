class ChatsController < ApplicationController
  def index
    @conversations = Conversation.all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("conversations", partial: "conversations/conversations", locals: { conversations: @conversations })
      end
      format.html { render "index" }
    end
  end

  def show
    @conversation = Conversation.find(params[:conversation_id])
    @messages = @conversation.messages.order(created_at: :desc)
  end

  def create
    @conversation = Conversation.find(params[:message][:conversation_id])
    @message = @conversation.messages.build(
      session_id: @conversation.session_id,
      role: "user",
      content: params[:message][:message]
    )

    if @message.save
      # Enqueue the AI chat job
      AiChatJob.perform_later(params[:message][:message], @conversation.id, params[:message][:model])

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message })
        end
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("error", partial: "shared/error", locals: { message: "Failed to send message" })
        end
        format.html { redirect_to @conversation, alert: "Failed to send message" }
      end
    end
  end

  def update
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.find(params[:message_id])

    if @message.update(message_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("message_#{@message.id}", partial: "messages/message", locals: { message: @message })
        end
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("error", partial: "shared/error", locals: { message: "Failed to update message" })
        end
        format.html { redirect_to @conversation, alert: "Failed to update message" }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :model)
  end
end
