module ApplicationHelper
  def copyright_notice
    years = (2015..Date.today.year).to_a.map(&:to_s)
    years = [ years.first, years.last ].uniq.join('-')
    "@ #{years} Nix. All Rights Reserved."
  end
end
