# frozen_string_literal: true

class HeaderCell < Cell::ViewModel
  def show
    render
  end

  def nav_cell_options
    {}.tap do |opts|
      opts[:affix] = options[:nav_affix] if options.key?(:nav_affix)
      opts[:back_to_top] = options[:nav_back_to_top] if options.key?(:nav_back_to_top)
    end
  end

  def content
    @options[:content].call
  end

  def css_class
    @options.key?(:class) ? @options[:class] : 'jumbo-header'
  end

  def background
    @options[:background] || asset_path('/assets/header-bg.jpg')
  end

  def style
    "background-image: url(#{background})" unless @options[:background].eql?(false)
  end
end
