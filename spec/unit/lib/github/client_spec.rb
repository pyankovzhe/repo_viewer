# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Github::Client do
  subject { described_class.new(api_endpoint, token) }
  let(:api_endpoint) { ENV['API_ENDPOINT'] }
  let(:token) { 'fake' }
  let(:owner) { 'matz' }

  describe '#repositories' do
    let(:repositories) { fixture('repositories.json') }
    let(:invalid_repositories) { fixture('invalid_owner_login.json') }

    context 'valid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, repositories, 200)
      end

      it 'returns response object with valid data' do
        result = subject.repositories(owner: owner)
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be true
        expect(result.data).to eq repositories['data']
      end
    end

    context 'invalid repository owner name' do
      before do
        stub_typhoeus_request(api_endpoint, invalid_repositories, 200)
      end

      it 'returns array of errors' do
        result = subject.repositories(owner: 'invalid_name')
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be false
        expect(result.errors)
          .to include invalid_repositories['errors'][0]['message']
      end
    end

    context 'response error 500' do
      before do
        stub_typhoeus_request(api_endpoint, repositories, 500)
      end

      it 'returns error' do
        result = subject.repositories(owner: owner)
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be false
        expect(result.errors).to eq '500 Unknown error'
      end
    end
  end

  describe '#repository' do
    let(:repository) { fixture('repository.json') }
    let(:repository_name) { 'streem' }

    let(:invalid_repository) { fixture('invalid_repository_name.json') }

    context 'valid repository name' do
      before do
        stub_typhoeus_request(api_endpoint, repository, 200)
      end

      it 'returns response object with valid data' do
        result = subject.repository(owner: owner, name: repository_name)
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be true
        expect(result.data).to eq repository['data']
      end
    end

    context 'invalid repository name' do
      before do
        stub_typhoeus_request(api_endpoint, invalid_repository, 200)
      end

      it 'returns array of errors' do
        result = subject.repository(owner: owner, name: 'invalid')
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be false
        expect(result.errors)
          .to include invalid_repository['errors'][0]['message']
      end
    end

    context 'response error 500' do
      before do
        stub_typhoeus_request(api_endpoint, repository, 500)
      end

      it 'returns array of errors' do
        result = subject.repository(owner: owner, name: repository_name)
        expect(result).to be_kind_of(Github::Response)
        expect(result.success?).to be false
        expect(result.errors).to eq '500 Unknown error'
      end
    end
  end
end
