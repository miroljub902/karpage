# frozen_string_literal: true

class PagesController < ApplicationController
  layout 'simple'

  def show
    return render_404 unless valid_page?
    render params[:id]
  end

  private

  def valid_page?
    file = Rails.root.join('app/views/pages', "#{params[:id].tr('..', '')}.*")
    Dir[file].reject { |f| %w[. ..].include?(File.basename(f)) }.any?
  end
end
