# frozen_string_literal: true

json.call(photo, :id, :created_at)
json.image_url ix_refile_image_url(photo, :image)
