# frozen_string_literal: true

module ApplicationHelper
  def self.auto_link(text)
    Rinku.auto_link(
      text
        .gsub(/([\s>])([\w-]+?\.com\b)/, '\1<a href="http://\2" target="_blank" rel="nofollow">\2</a>')
        .gsub(/^([\w-]+?\.com\b)/, '<a href="http://\1" target="_blank" rel="nofollow">\1</a>'),
      :all,
      'target="_blank" rel="nofollow"'
    ).html_safe
  end

  def auto_link(text)
    ApplicationHelper.auto_link(text)
  end

  def my_profile?
    current_user && @user && current_user.id == @user.id
  end

  def flash_class(key)
    {
      notice: 'alert-info',
      alert: 'alert-warning'
    }[key.to_sym]
  end

  def copyright_notice
    years = (2015..Time.zone.today.year).to_a.map(&:to_s)
    years = [years.first, years.last].uniq.join('-')
    "@ #{years} Kar Page Inc. All Rights Reserved."
  end

  def param?(key, default = false)
    params[key].present? ? params[key] == 'true' : default
  end

  def new_count_indicator(stuff, owner:, reset: false)
    count = count_new_stuff(stuff, owner: owner)
    return if count.zero?
    if reset
      NewStuff.reset_count stuff, current_user, owner: owner, delay: reset == :delay
    end
    content_tag :div, count, class: 'new-count'
  end
end
