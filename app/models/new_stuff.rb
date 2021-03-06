# frozen_string_literal: true

class NewStuff < ApplicationRecord
  belongs_to :user
  belongs_to :stuff_owner, class_name: 'User'

  validates :user, :stuff, presence: true

  def self.count_stuff(stuff, user, owner:)
    counter = get_counter(stuff, user, owner: owner)
    stuff = stuff.object if stuff.is_a?(Draper::CollectionDecorator)
    stuff.where("#{stuff_class(stuff).table_name}.created_at > ?", counter.last_at).count
  end

  def self.reset_count(stuff, user, owner:, delay: false)
    return unless user
    get_counter(stuff, user, owner: owner).reset!(delay)
  end

  def reset!(delay = false)
    update_attribute :last_at, Time.zone.now - (delay ? 10.seconds : 0)
  end

  def self.stuff_class(stuff)
    stuff.is_a?(ActiveRecord::Relation) ? stuff : stuff.first.class
  end

  def self.get_counter(stuff, user, owner:)
    klass = stuff_class(stuff).name.sub(/Decorator$/, '')
    find_or_initialize_by(user: user, stuff: klass, stuff_owner: owner).tap do |counter|
      counter.last_at ||= Time.zone.now
      counter.save! if counter.has_changes_to_save?
    end
  end
end
