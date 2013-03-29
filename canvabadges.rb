require 'sinatra/base'
require 'oauth'
require 'json'
require 'dm-core'
require 'dm-migrations'
require 'nokogiri'
require 'oauth/request_proxy/rack_request'
require 'ims/lti'
require 'digest/md5'
require 'net/http'

require './lib/models.rb'
require './lib/oauth.rb'
require './lib/api.rb'
require './lib/badge_configuration.rb'
require './lib/views.rb'

class Canvabadges < Sinatra::Base
  register Sinatra::OAuth
  register Sinatra::Api
  register Sinatra::BadgeConfiguration
  register Sinatra::Views
  
  # sinatra wants to set x-frame-options by default, disable it
  disable :protection
  # enable sessions so we can remember the launch info between http requests, as
  # the user takes the assessment
  enable :sessions
  raise "session key required" if ENV['RACK_ENV'] == 'production' && !ENV['SESSION_KEY']
  set :session_secret, ENV['SESSION_KEY'] || "local_secret"

  env = ENV['RACK_ENV'] || settings.environment
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/#{env}.sqlite3"))
  DataMapper.auto_upgrade!
end

