class HeaderCell < Cell::ViewModel
  def show
    render
  end

  def content
    @options[:content].call
  end

  def background
    "url(#{asset_path('/assets/header-bg.jpg')})"
  end
end
