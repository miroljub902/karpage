class HeaderCell < Cell::ViewModel
  def show
    render
  end

  def content
    @options[:content].call
  end

  def css_class
    @options.has_key?(:class) ? @options[:class] : 'jumbo-header'
  end

  def background
    "url(#{asset_path('/assets/header-bg.jpg')})"
  end
end
