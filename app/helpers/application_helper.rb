module ApplicationHelper
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
    years = (2015..Date.today.year).to_a.map(&:to_s)
    years = [ years.first, years.last ].uniq.join('-')
    "@ #{years} Kar Page Inc. All Rights Reserved."
  end

  # There's a bug that in production causes the cell's contents
  # to return as escaped HTML, so we have to explicitly call ".()"
  # Also allows block render-yield as a convenience
  def cell(name, model = nil, options = {})
    options = options.dup
    options.merge!(content: -> {
      capture { yield }
    }) if block_given?
    controller.cell(name, model, options).()
  end

  def param?(key, default = false)
    params[key].present? ? params[key] == 'true' : default
  end

  def new_count_indicator(stuff, owner:, reset: false)
    count = count_new_stuff(stuff, owner: owner)
    return if count == 0
    if reset
      NewStuff.reset_count stuff, current_user, owner: owner, delay: reset == :delay
    end
    content_tag :div, count, class: 'new-count'
  end
end
