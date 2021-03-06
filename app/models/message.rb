class Message < ApplicationRecord
  include ActionView::Helpers::DateHelper
  belongs_to :network, required: false
  has_many :images

  has_many :user_likes
  has_many :liked_users, through: :user_likes, class_name: 'User'

  has_many :locked_messages
  has_many :locked_users, through: :locked_users, class_name: 'User'

  has_many :legendary_likes
  has_many :legendary_users, through: :legendary_likes, class_name: 'User'

  has_many :deleted_messages
  has_many :users, through: :deleted_messages

  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"

  attr_accessor :current_user

  def self.without_deleted(user_id, undercover)
    ids = DeletedMessage.where(user_id: user_id, undercover: undercover).pluck(:message_id)
    Message.where(id: ids)
  end

  def image_urls
    urls = []
    images.each do |image|
      puts ActionController::Base.helpers.asset_path(image.image.url(:medium))
      urls << 'https:'+image.image.url(:medium) #ActionController::Base.helpers.asset_path(image.image.url(:medium))
    end
    urls
  end

  def post_url
    post_permalink.present? ? URI.decode(post_permalink) : ''
  end

  def deleted_by_user?(user=nil)
    user ||= current_user
    users.include?(user)
  end

  def like_by_user(user=nil)
    user ||= current_user
    liked_users.include?(user)
  end

  def legendary_by_user(user=nil)
    user ||= current_user
    legendary_users.include?(user)
  end

  def locked_by_user(user=nil)
    user ||= current_user
    # locked_users.include?(user)
    m = LockedMessage.find_by(message_id: self.id, user_id: user.id)
    m.present? && m.unlocked != true
  end

  def save_password(password)
    self.password_salt = SecureRandom.base64(8)
    self.password_hash = Digest::SHA2.hexdigest(password_salt + password)
    save
  end

  def text_with_links
    urls_with_tags = []
    if self.text.present?
      links = URI.extract(self.text)
      new_message = remove_uris(self.text)
      links.each do |link|
        new_message += ' <a href="' + link + '">' + link + '</a> '
      end if links.present?
      new_message
    else
      new_message = self.text
    end
  end

  def remove_uris(text)
    text.split(URI_REGEX).collect do |s|
      unless s =~ URI_REGEX
        s
      end
    end.join
  end

  def correct_password?(password)
    password_hash == Digest::SHA2.hexdigest(password_salt + password)
  end

  def user
    u = User.find_by(id: user_id)
    u.as_json(methods: [:avatar_url, :hero_avatar_url], only: [:name, :role_name])
  end

  def expire_at
    expire_date.present? ? distance_of_time_in_words(Time.now, expire_date) : ''
  end

  def has_expired
    expire_date.present? && DateTime.now > expire_date
  end
end
