class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :title, presence: true
  validates :session_id, presence: true, uniqueness: true

  before_validation :generate_session_id, unless: :session_id?

  # Generate a unique session ID using SessionService
  def self.generate_session_id
    SessionService.generate_session_id
  end

  private

  def generate_session_id
    self.session_id ||= SessionService.generate_session_id
  end
end
