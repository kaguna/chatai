class Message < ApplicationRecord
  belongs_to :conversation

  validates :session_id, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant system] }
  validates :content, presence: true
end
