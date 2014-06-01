# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  screen_name     :string(255)      not null
#  twitter_user_id :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#

require 'twitter_session'
require 'open-uri'

class User < ActiveRecord::Base
  attr_accessible(:twitter_user_id, :screen_name)

  validates :screen_name, :twitter_user_id, presence: true
  validates :screen_name, :twitter_user_id, uniqueness: true

  has_many :statuses, 
  class_name: "Status", 
  foreign_key: :twitter_user_id, 
  primary_key: :twitter_user_id

  def self.fetch_by_screen_name!(screen_name)
    fetched_user_params = TwitterSession.get("users/show", {screen_name: screen_name})
    
    fetched_user = self.parse_twitter_user(fetched_user_params)

    fetched_user.save!

    fetched_user
  end

  def self.get_by_screen_name(screen_name)
    user = User.find_by_screen_name(screen_name)

    if user.nil?
      user = User.fetch_by_screen_name!(screen_name)
    end

    user
  end

  def self.parse_twitter_user(user_params)
    User.new(
      screen_name: user_params["screen_name"], 
      twitter_user_id: user_params["id_str"]
    )
  end

  def fetch_statuses!
    Status.fetch_by_twitter_user_id!(self.twitter_user_id)
  end
end
