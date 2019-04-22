# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/github/client'

class App < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    set :server, :puma
    set :port, 4000
    enable :logging
    enable :sessions

    set :github, Github::Client.new(ENV['API_ENDPOINT'], ENV['TOKEN'])
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    slim :home
  end

  get '/search' do
    if params['owner'].nil? || params['owner'].empty?
      flash :errors, 'Owner can not be blank'
      redirect_to_root
    else
      redirect path_to_repositories(params['owner'])
    end
  end

  get '/:owner/repositories' do
    @owner = params['owner']
    response = settings.github.repositories(owner: @owner)

    if response.success?
      @repositories = response.data.dig('user', 'repositories', 'nodes')
      slim :'repositories/index'
    else
      flash :errors, response.errors
      redirect_to_root
    end
  end

  get '/:owner/repositories/:name' do
    @owner = params['owner']
    response = settings.github.repository(owner: @owner, name: params['name'])

    if response.success?
      @repo = response.data.fetch('repository', [])
      @commits = @repo.dig('defaultBranchRef', 'target', 'history', 'nodes')
      slim :'repositories/show'
    else
      flash :errors, response.errors
      redirect_to_root
    end
  end

  helpers do
    def flash(key, data)
      session[key] ||= []
      session[key].push(*data)
    end

    def flash_errors
      return @flash_errors if defined? @flash_errors

      @flash_errors = session[:errors]
      session[:errors] = nil
      @flash_errors
    end

    def redirect_to_root
      redirect to '/'
    end

    def path_to_repositories(owner)
      File.join('/', owner, 'repositories')
    end

    def path_to_repository(owner, name)
      File.join('/', owner, 'repositories', name)
    end
  end
end
