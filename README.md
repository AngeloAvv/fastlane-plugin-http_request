# http_request plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-http_request)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-http_request`, add it to your project by running:

```bash
fastlane add_plugin http_request
```

## About http_request

Fastlane plugin to send http requests

* Supports GET, POST, PUT, PATCH, and DELETE
* Handles JSON or raw body payloads
* Optional timeout and verbose logging
* Gracefully handles errors and unsupported methods
* Returns structured data:
```
{
    code: 200,
    body: {...},
    headers: {...}
}
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

```
lane :test do
  response = http_request(
    url: "https://httpbin.io/post",
    method: "POST",
    headers: { "Content-Type" => "application/json" },
    body: {
      app: "appName",
      version: "1.0",
      build: 123,
      environment: "production"
    },
    verbose: true
  )

  UI.message("Webhook returned code: #{response[:code]}")
  UI.message("Response: #{response[:body]}")
end
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
