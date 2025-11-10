# config/initializers/active_storage.rb
require "image_processing/mini_magick"
Rails.application.config.active_storage.variant_processor = :mini_magick
