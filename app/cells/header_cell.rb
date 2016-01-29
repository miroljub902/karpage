class HeaderCell < Cell::ViewModel
  def show
    render
  end

  def nav_cell_options
    {}.tap do |opts|
      opts[:affix] = options[:nav_affix] if options.has_key?(:nav_affix)
      opts[:back_to_top] = options[:nav_back_to_top] if options.has_key?(:nav_back_to_top)
    end
  end

  def content
    @options[:content].call
  end

  def css_class
    @options.has_key?(:class) ? @options[:class] : 'jumbo-header'
  end

  def background
    @options[:background] || asset_path('/assets/header-bg.jpg')
  end

  def style
    "background-image: url(#{background})" unless @options[:background] === false
  end
end
