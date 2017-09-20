# frozen_string_literal: true

module Views
  class HeaderDecorator < ViewDecorator
    def render(&block)
      content = capture(&block)
      content_tag :div, style: style, class: css_class do
        Views::NavDecorator.new(nav_options).render +
          content_tag(:div, content, class: 'header-content')
      end
    end

    def css_class
      options.key?(:class) ? options[:class] : 'jumbo-header'
    end

    def background
      options[:background] || asset_path('/assets/header-bg.jpg')
    end

    def style
      "background-image: url(#{background})" unless options[:background].eql?(false)
    end

    private

    def nav_options
      {}.tap do |opts|
        opts[:affix] = options[:nav_affix] if options.key?(:nav_affix)
        opts[:back_to_top] = options[:nav_back_to_top] if options.key?(:nav_back_to_top)
      end
    end
  end
end
