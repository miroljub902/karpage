class NavCell < Cell::ViewModel
  def show
    render
  end

  def affix?
    options.has_key?(:affix) ? options[:affix] : true
  end

  def back_to_top?
    options.has_key?(:back_to_top) ? options[:back_to_top] : false
  end

  def transparent?
    !!options[:transparent]
  end

  def current_user
    controller.send :current_user
  end
end
