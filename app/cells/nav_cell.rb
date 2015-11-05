class NavCell < Cell::ViewModel
  def show
    render
  end

  def current_user
    controller.send :current_user
  end
end
