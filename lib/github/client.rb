# frozen_string_literal: true

require 'typhoeus'
require_relative 'response'

module Github
  class Client
    attr_reader :endpoint, :token

    def initialize(endpoint, token)
      @endpoint = endpoint
      @token = token
    end

    def run(query)
      result = request(query: query).run
      Github::Response.new(result)
    end

    def repositories(owner:, last: 100)
      run <<~QUERY.strip
        query {
          user(login: "#{owner}") {
            repositories(last: #{last}, ownerAffiliations: OWNER) {
              nodes {
                name
              }
            }
          }
        }
      QUERY
    end

    def repository(name:, owner:, first: 100)
      run <<~QUERY.strip
        query {
          repository(owner:"#{owner}", name:"#{name}") {
            name
            createdAt
            url
            defaultBranchRef {
              target {
                ... on Commit {
                  history(first: #{first}) {
                    nodes {
                      oid
                      message
                      committedDate
                      url
                    }
                  }
                }
              }
            }
          }
        }
      QUERY
    end

    def type_details(type)
      run <<~QUERY.strip
        query {
          __type(name: "#{type}") {
            name
            kind
            description
            fields {
              name
              description
              type {
                name
                kind
              }
            }
          }
        }
      QUERY
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "bearer #{token}",
      }
    end

    def request(method: :post, query:)
      options = {
        method: method,
        headers: headers,
      }
      options[:body] = { query: query }.to_json unless query.nil?

      connection(options)
    end

    def connection(options)
      Typhoeus::Request.new(endpoint, options)
    end
  end
end
