# frozen_string_literal: true

require 'spec_helper'

RSpec.describe App do
  def app
    App
  end

  let(:api_endpoint) { ENV['API_ENDPOINT'] }
  let(:token) { 'fake' }
  let(:owner) { 'matz' }

  describe 'GET /' do
    it 'renders home page with search form' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Search for repositories by owner')
    end
  end

  describe 'GET /search' do
    let(:repositories) { fixture('repositories.json') }
    let(:invalid_login_response) { fixture('invalid_owner_login.json') }

    context 'valid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, repositories, 200)
      end

      it 'redirects to owners repositories' do
        get "/search?owner=#{owner}"
        follow_redirect!
        expect(last_response).to be_ok
        repositories_names = repositories
                             .dig('data', 'user', 'repositories', 'nodes')
                             .map { |node| node['name'] }
        expect(last_response.body).to include(*repositories_names)
      end
    end

    context 'empty repository owner name' do
      it 'renders errors' do
        get '/search'
        follow_redirect!
        expect(last_response).to be_ok
        expect(last_response.body).to include 'Owner can not be blank'
      end
    end
  end

  describe 'GET repositories' do
    let(:repositories) { fixture('repositories.json') }
    let(:invalid_response) { fixture('invalid_owner_login.json') }

    context 'valid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, repositories, 200)
      end

      it 'renders repositories' do
        get repositories_path(owner)
        expect(last_response).to be_ok
        repositories_names = repositories
                             .dig('data', 'user', 'repositories', 'nodes')
                             .map { |node| node['name'] }
        expect(last_response.body).to include(*repositories_names)
      end
    end

    context 'invalid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, invalid_response, 200)
      end

      it 'renders errors' do
        get repositories_path('invalid')
        follow_redirect!
        expect(last_response).to be_ok
        expect(last_response.body).to include('Errors:')
        error_message = invalid_response['errors'][0]['message']
        expect(last_response.body).to include error_message
      end
    end
  end

  describe 'GET repository' do
    let(:repository_name) { 'streem' }
    let(:repository) { fixture('repository.json') }
    let(:invalid_response) { fixture('invalid_repository_name.json') }

    context 'valid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, repository, 200)
      end

      it 'renders repositories' do
        get repository_path(owner, repository_name)
        expect(last_response).to be_ok
        keys = %w[data repository defaultBranchRef target history nodes]
        commits_ids = repository.dig(*keys).map { |node| node['oid'] }
        expect(last_response.body).to include(*commits_ids)
      end
    end

    context 'invalid repository name' do
      before do
        stub_typhoeus_request(api_endpoint, invalid_response, 200)
      end

      it 'renders errors' do
        get repository_path(owner, 'invalid')
        follow_redirect!
        expect(last_response).to be_ok
        expect(last_response.body).to include('Errors:')
        error_message = invalid_response['errors'][0]['message']
        expect(last_response.body).to include error_message
      end
    end
  end
end
