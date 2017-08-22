# frozen_string_literal: true

class NavCell < Cell::ViewModel
  def show
    render
  end

  def affix?
    options.key?(:affix) ? options[:affix] : true
  end

  def back_to_top?
    options.key?(:back_to_top) ? options[:back_to_top] : false
  end

  def transparent?
    options[:transparent].nil? ? false : options[:transparent]
  end

  def current_user
    controller.__send__ :current_user
  end
end
