require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module MemeApi
  class Application < Rails::Application
    config.to_prepare do
      DeviseController.respond_to :json
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    class NullSessionStore < ActionDispatch::Session::AbstractStore
      def initialize(app, options = {})
        super
      end

      def get_session(env, sid)
        sid ||= generate_sid
        [sid, {}]
      end

      def set_session(env, sid, session, options)
        sid
      end

      def destroy_session(env, sid, options)
        generate_sid
      end
    end

    config.middleware.use NullSessionStore
  end
end
