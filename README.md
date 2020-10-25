# cookbook_release_validator

Checks that the version number in metadata.rb on the pull request is the same as the default branch

## Configuration

### Environment Variables

This app uses the following environments variables:

| Name | Required | Description |
| ---| --- | ---|
| GITHUB_TOKEN| Yes| Token to access the github api, this will be used to write the status to the pr |
| SECRET_TOKEN | No| If supplied it will do a HMAC check against the incomming request |

### Webhook

To configure the webhook you will want to do the following:

URL: <https://example.com/handler>
Events:
  Let me select:
    Pull Requests (Only)

If you set a HMAC secret ensure that `SECRET_TOKEN` is set to the same secret value

## Docker images

Docker images are supplied under Xorima on docker hub, <https://hub.docker.com/r/xorima/cookbook_release_validator/>
