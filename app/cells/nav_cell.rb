class NavCell < Cell::ViewModel
  def show
    render
  end

  def transparent?
    !!options[:transparent]
  end

  def current_user
    controller.send :current_user
  end
end
