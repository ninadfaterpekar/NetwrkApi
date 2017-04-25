class Message < ApplicationRecord
  belongs_to :network
  has_many :images
  has_many :user_likes

  has_many :deleted_messages
  has_many :users, through: :deleted_messages

  attr_accessor :current_user

  def image_urls
    urls = []
    images.each do |image|
      urls << image.image.url
    end
    urls
  end

  def deleted_by_user?(user=nil)
    user ||= current_user
    users.include?(user)
  end

  def save_password(password)
    self.password_salt = ActiveSupport::SecureRandom.base64(8)
    self.password_hash = Digest::SHA2.hexdigest(password_salt + password)
    save
  end

  def correct_password?(password)
    password_hash == Digest::SHA2.hexdigest(password_salt + password)
  end
end
