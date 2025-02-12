# frozen_string_literal: true

# Single file Rails application setup following
# https://greg.molnar.io/blog/a-single-file-rails-application/

require 'bundler/setup'
require 'rails'
# Pick the frameworks you want:
# require 'active_model/railtie'
# require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
# require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
# require 'action_view/railtie'
# require 'action_cable/engine'
# require 'rails/test_unit/railtie'

database = 'development.sqlite3'
ENV['DATABASE_URL'] = "sqlite3:#{database}"
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: database)
ActiveRecord::Base.logger = Logger.new($stdout)

class App < Rails::Application
  config.root = __dir__
  config.consider_all_requests_local = true
  config.secret_key_base = 'super_secret_key_for_dev'
  config.active_support.cache_format_version = 7.1

  # These configurations are required for proper streaming functionality
  # https://api.rubyonrails.org/classes/ActionController/Live.html
  config.allow_concurrency = true
  config.preload_frameworks = true
  config.eager_load = true

  routes.append do
    root to: 'stream#counter'
    get 'healthz' => 'rails/health#show', as: :rails_health_check
  end
end

class StreamController < ActionController::Base
  # Include streaming capabilities
  # https://api.rubyonrails.org/classes/ActionController/Live.html
  include ActionController::Live

  before_action :set_headers

  def counter
    count = 1

    begin
      duration.times do
        response.stream.write("Counter: #{count}\n")
        count += 1
        sleep 1
      end
    rescue IOError
      Rails.logger.info 'Client disconnected'
    ensure
      response.stream.close
    end
  end

  private

  def set_headers
    # Set content type to plain text for simple counter output
    response.headers['Content-Type'] = 'text/plain'

    # Add Rack 2.2.x compatibility header if requested
    # https://api.rubyonrails.org/classes/ActionController/Live.html
    response.headers['Last-Modified'] = Time.now.httpdate if rack2_compatibility

    # Add fly.io specific header if requested
    # https://community.fly.io/t/http-response-streaming-not-working-on-fly-io/23580
    response.headers['Content-Encoding'] = 'identity' if fly_io_mode
  end

  def duration
    (params[:duration] || 20).to_i
  end

  def rack2_compatibility
    params[:rack2].present?
  end

  def fly_io_mode
    params[:fly].present?
  end
end

App.initialize!
run App
