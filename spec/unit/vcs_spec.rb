# frozen_string_literal: true

require 'spec_helper'

describe CookbookReleaseValidator::Vcs, :vcr do
  # Check Vcs creates an OctoKit client
  before(:each) do
    pull_request = { 'base' => { 'ref' => 'master', 'repo' => { 'default_branch' => 'master', 'full_name' => 'Xorima/xor_test_cookbook' } },
                     'head' => { 'sha' => 'c61d90283be7b931ade7d3504f67190dac1012c6', 'ref' => 'fork_foo', 'repo' => {'full_name' => 'xorimabot/xor_test_cookbook'} },
                     'number' => 22 }
    @client = CookbookReleaseValidator::Vcs.new({
                                            token: ENV['GITHUB_TOKEN'] || 'temp_token',
                                            pull_request: pull_request
                                          })
  end

  it 'creates an octkit client' do
    expect(@client).to be_kind_of(CookbookReleaseValidator::Vcs)
  end

  it 'returns true if the pull request is against the default branch' do
    expect(@client.default_branch_target?).to eq true
  end

  it 'creates a pending status check' do

    expect(@client.status_check(state: 'pending')[:state]).to eq 'pending'
  end

  it 'creates a failed status check' do
    expect(@client.status_check(state: 'failure')[:state]).to eq 'failure'
  end

  it 'creates a sucessful status check' do
    expect(@client.status_check(state: 'success')[:state]).to eq 'success'
  end

  it 'gets the default branch metadata version' do
    expect(@client.default_metadata_version).to eq '3.5.999'
  end

  it 'gets the branch metadata version' do
    expect(@client.branch_metadata_version).to eq 'lol'
  end
end
