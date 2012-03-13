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
CourseReserves::Application.config.future_terms = ["Summer 2012", "Fall 2012"]
CourseReserves::Application.config.reserve_libraries = { 
  "ART-RESV" => "Art Library",
  "BIO-RESV" => "Biology Library",
  "CHEM-RESV" => "Chemistry Library",
  "EARTH-RESV" => "Earth Sciences Library",
  "EAS-RESV" => "East Asia Library",
  "EDU-RESV" => "Education Library",
  "ENG-RESV" => "Engineering Library",
  "GREEN-RESV" => "Green Library",
  "HOP-RESV" => "Marine Biology Library",
  "LAW-RESV" => "Law Library",
  "MATH-RESV" => "Math Library",
  "MEDIA-RESV" => "Media Microtext",
  "MUSIC-RESV" => "Music Library"
}
CourseReserves::Application.config.email_mapping = { 
  "ART-RESV" => "artlibrary@stanford.edu",
  "BIO-RESV" => "falconerlibrary@stanford.edu, zeynepb@stanford.edu, cwelborn@stanford.edu",
  "CHEM-RESV" => "swainlibrary@stanford.edu",
  "EARTH-RESV" => "brannerlibrary@stanford.edu",
  "EAS-RESV" => "eastasialibrary@stanford.edu",
  "EDU-RESV" => "cubberley@stanford.edu, kells@stanford.edu",
  "ENG-RESV" => "englibrary@stanford.edu",
  "GREEN-RESV" => "greenreserves@stanford.edu",
  "HOP-RESV" => "hms-library@mailman.stanford.edu",
  "LAW-RESV" => "crowncirc@lists.stanford.edu",
  "MATH-RESV" => "mathstatlib@stanford.edu, zeynepb@stanford.edu, jshen@stanford.edu",
  "MEDIA-RESV" => "mediamtxt@lists.stanford.edu",
  "MUSIC-RESV" => "muslibcirc@stanford.edu"
}
CourseReserves::Application.config.loan_periods = {
  "2HWF-RES"   => "2 hours",
  "4HWF-RES"   => "4 hours",
  "1DNDWF-RES" => "1 day",
  "2DWF-RES"   => "2 days",
  "3DWF-RES"   => "3 days"
}
CourseReserves::Application.config.super_sunets = %w[seestone jleggett laszloj mwh hoangl mholloma cherylc1 ssaini rruelas hmalcolm leiferik suziek dgaghan alvarezj cdescanz rwmantov quiambao daisun jjamison asharma4 bclaus rchaelv mnack ifadakar tcruzada linday zeynepb jshen rwedl cwelborn skota jwible dkohrs vpearse kells eshelton kkerns bbousman rpowers raymondh jlmcbrid nlorimer jlavigne jvine jkeck dlrueda tcramer rns makeller ctierney mchris pernell rachaelv carlinot sgendel jshaikh nrz evwayne plomio rsamberg gwilson adelgado sstone2 kwinzer wilsosa cannie albah smoss bcalhoun ldrews sisien kkuehl yunqi teasland vizvary guofenjw cnaranch tbukina tut lwchen rtamares annemj rporter syliang lindapc]