require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module CourseReserves
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end

end
CourseReserves::Application.config.current_term = "Spring 2012"
CourseReserves::Application.config.reserve_libraries = { 
  "artlibrary@stanford.edu" => "Art Library",
  "falconerlibrary@stanford.edu, zeynepb@stanford.edu, cwelborn@stanford.edu" => "Biology Library",
  "swainlibrary@stanford.edu" => "Chemistry Library",
  "brannerlibrary@stanford.edu" => "Earth Sciences Library",
  "eastasialibrary@stanford.edu" => "East Asia Library",
  "cubberley@stanford.edu, kells@stanford.edu" => "Education Library",
  "englibrary@stanford.edu" => "Engineering Library",
  "greenreserves@stanford.edu" => "Green Library",
  "hoovercirc@hoover.stanford.edu" => "Hoover Library",
  "hms-library@mailman.stanford.edu" => "Marine Biology Library",
  "crowncirc@lists.stanford.edu" => "Law Library",
  "mathstatlib@stanford.edu, zeynepb@stanford.edu, jshen@stanford.edu" => "Math Library",
  "mediamtxt@lists.stanford.edu" => "Media Microtext Library",
  "muslibcirc@stanford.edu" => "Music Library",
  "tanner-library@stanford.edu" => "Philosophy Library"
}
CourseReserves::Application.config.load_periods = ["2 hours", "4 hours", "1 day", "2 days", "3 days"]
CourseReserves::Application.config.super_sunets = %w[seestone jleggett laszloj mwh hoangl mholloma cherylc1 ssaini rruelas hmalcolm leiferik suziek dgaghan alvarezj cdescanz rwmantov quiambao daisun jjamison asharma4 bclaus rchaelv mnack ifadakar tcruzada linday zeynepb jshen rwedl cwelborn skota jwible dkohrs vpearse kells eshelton kkerns bbousman rpowers raymondh jlmcbrid nlorimer jlavigne jvine jkeck dlrueda tcramer rns makeller ctierney mchris]