# frozen_string_literal: true

require 'octokit'

module CookbookReleaseValidator
  # Used to handle calls to VCS
  class Vcs
    def initialize(token:, pull_request:)
      @client = Octokit::Client.new(access_token: token)
      @repository_name = pull_request['base']['repo']['full_name']
      @pull_request = pull_request
    end

    def default_branch_target?
      @pull_request['base']['ref'] == @pull_request['base']['repo']['default_branch']
    end

    def default_metadata_version
      repo = @repository_name
      branch = @pull_request['base']['ref']
      metadata_version(repo, branch)
    end

    def branch_metadata_version
      repo = @pull_request['head']['repo']['full_name']
      branch = @pull_request['head']['ref']
      v = metadata_version(repo, branch)
      raise IOError if v == ''

      v
    end

    def status_check(state:)
      raise ArgumentError, 'State must be pending, success, failure' unless %w[pending success failure].include?(state)

      @client.create_status(@repository_name,
                            @pull_request['head']['sha'],
                            state,
                            { context: 'Metadata Version Validator',
                              description: 'Ensuring version number in metadata.rb has not changed' })
    end

    private

    def metadata_version(repo_name, ref)
      file = get_file_contents(repo_name, 'metadata.rb', ref)
      m = file['content'].match(/\n(version\s+'(.+)')\n/m)
      if m
        m[2]
      else
        '' # This should never match
      end
    end

    def get_file_contents(repo_name, file_path, ref)
      file_content = @client.contents(repo_name, path: file_path, ref: ref)
      content = Base64.decode64(file_content[:content])
      response = {}
      response['content'] = content
      response['sha'] = file_content[:sha]
      response
    end
  end
end
