module ApplicationHelper
  def copyright_notice
    years = (2015..Date.today.year).to_a.map(&:to_s)
    years = [ years.first, years.last ].uniq.join('-')
    "@ #{years} Nix. All Rights Reserved."
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
end
