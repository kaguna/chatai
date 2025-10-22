class SessionService
  # Generate a unique session ID
  def self.generate_session_id
    loop do
      session_id = SecureRandom.uuid
      break session_id unless Conversation.exists?(session_id: session_id)
    end
  end

  # Generate a shorter, more readable session ID (optional alternative)
  def self.generate_short_session_id
    loop do
      # Generate a 12-character alphanumeric session ID
      session_id = SecureRandom.alphanumeric(12)
      break session_id unless Conversation.exists?(session_id: session_id)
    end
  end

  # Generate a session ID with timestamp prefix for better organization
  def self.generate_timestamped_session_id
    loop do
      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      random_part = SecureRandom.hex(4)
      session_id = "#{timestamp}_#{random_part}"
      break session_id unless Conversation.exists?(session_id: session_id)
    end
  end

  # Validate if a session ID is valid format
  def self.valid_session_id?(session_id)
    return false if session_id.blank?
    # Check if it's a valid UUID format
    session_id.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
  end
end
