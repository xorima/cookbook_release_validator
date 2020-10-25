# frozen_string_literal: true

require 'sinatra'

require_relative 'cookbookreleasevalidator/vcs'
require_relative 'cookbookreleasevalidator/hmac'

get '/' do
  'Alive'
end

post '/handler' do
  return halt 500, "Signatures didn't match!" unless validate_request(request)

  payload = JSON.parse(params[:payload])

  case request.env['HTTP_X_GITHUB_EVENT']
  when 'pull_request'
    if %w[labeled unlabeled opened reopened synchronize].include?(payload['action'])
      vcs = CookbookReleaseValidator::Vcs.new(token: ENV['GITHUB_TOKEN'], pull_request: payload['pull_request'])
      return 'Only runs on Default branch' unless vcs.default_branch_target?

      vcs.status_check(state: 'pending')
      default_metadata_version = vcs.default_metadata_version
      begin
        branch_metadata_version = vcs.branch_metadata_version
      rescue StandardError
        vcs.status_check(state: 'failure')
        return halt 404, 'Unable to find branch metadata'
      end
      if version_diff(default_metadata_version, branch_metadata_version)
        vcs.status_check(state: 'failure')
        return 'Version number has been changed'
      else
        vcs.status_check(state: 'success')
        return 'Version number is the same'
      end
    end
  end
end

def validate_request(request)
  true unless ENV['SECRET_TOKEN']
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
end

def version_diff(default, branch)
  default != branch
end
