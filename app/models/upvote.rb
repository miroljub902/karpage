# frozen_string_literal: true

class Upvote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true, counter_cache: true
  belongs_to :user

  def self.toggle!(voteable, user)
    where(voteable: voteable, user: user).first_or_initialize.tap do |vote|
      vote.persisted? ? vote.destroy : vote.save!
    end
  end

  def self.vote!(voteable, user)
    where(voteable: voteable, user: user).first_or_create!
  end

  def self.unvote!(voteable, user)
    find_by(voteable: voteable, user: user).try(:destroy)
  end
end
