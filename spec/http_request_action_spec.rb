require 'fastlane/action'
require 'webmock/rspec'
require 'fastlane/plugin/http_request/actions/http_request_action'

describe Fastlane::Actions::HttpRequestAction do
  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  let(:url) { "https://api.example.com/resource" }

  it "sends a GET request successfully" do
    stub_request(:get, url)
      .to_return(status: 200, body: '{"message": "ok"}', headers: { 'Content-Type' => 'application/json' })

    result = Fastlane::Actions::HttpRequestAction.run(
      url: url,
      method: "GET"
    )

    expect(result[:code]).to eq(200)
    expect(result[:body]).to eq({ "message" => "ok" })
  end

  it "sends a POST request with JSON body" do
    stub_request(:post, url)
      .with(
        body: { "foo" => "bar" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(status: 201, body: '{"id": 123}', headers: { 'Content-Type' => 'application/json' })

    result = Fastlane::Actions::HttpRequestAction.run(
      url: url,
      method: "POST",
      headers: { "Content-Type" => "application/json" },
      body: { foo: "bar" }
    )

    expect(result[:code]).to eq(201)
    expect(result[:body]["id"]).to eq(123)
  end

  it "sends a PUT request with JSON body" do
    stub_request(:put, url)
      .with(
        body: { "name" => "Updated" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(status: 200, body: '{"updated": true}', headers: { 'Content-Type' => 'application/json' })

    result = Fastlane::Actions::HttpRequestAction.run(
      url: url,
      method: "PUT",
      headers: { "Content-Type" => "application/json" },
      body: { name: "Updated" }
    )

    expect(result[:code]).to eq(200)
    expect(result[:body]).to eq({ "updated" => true })
  end

  it "sends a PATCH request correctly" do
    stub_request(:patch, url)
      .with(
        body: { "status" => "active" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(status: 200, body: '{"patched": true}', headers: { 'Content-Type' => 'application/json' })

    result = Fastlane::Actions::HttpRequestAction.run(
      url: url,
      method: "PATCH",
      headers: { "Content-Type" => "application/json" },
      body: { status: "active" }
    )

    expect(result[:code]).to eq(200)
    expect(result[:body]).to eq({ "patched" => true })
  end

  it "sends a DELETE request successfully" do
    stub_request(:delete, "#{url}/123")
      .to_return(status: 204, body: "", headers: {})

    result = Fastlane::Actions::HttpRequestAction.run(
      url: "#{url}/123",
      method: "DELETE"
    )

    expect(result[:code]).to eq(204)
    expect(result[:body]).to eq("")
  end

  it "handles non-JSON responses gracefully" do
    stub_request(:get, url)
      .to_return(status: 200, body: "plain text response", headers: {})

    result = Fastlane::Actions::HttpRequestAction.run(url: url, method: "GET")

    expect(result[:body]).to eq("plain text response")
  end

  it "raises an error for unsupported HTTP method" do
    expect do
      Fastlane::Actions::HttpRequestAction.run(url: url, method: "INVALID")
    end.to raise_error(FastlaneCore::Interface::FastlaneError, /Unsupported HTTP method/)
  end

  it "handles request timeouts gracefully" do
    stub_request(:get, url).to_timeout

    expect do
      Fastlane::Actions::HttpRequestAction.run(url: url, method: "GET", timeout: 1)
    end.to raise_error(FastlaneCore::Interface::FastlaneError, /HTTP request failed/)
  end

  it "returns headers in the response hash" do
    stub_request(:get, url)
      .to_return(status: 200, body: '{"ok":true}', headers: { 'X-Custom' => 'HeaderValue' })

    result = Fastlane::Actions::HttpRequestAction.run(url: url, method: "GET")

    expect(result[:headers]).to include("x-custom" => "HeaderValue")
  end

  it "prints response body in verbose mode" do
    stub_request(:get, url)
      .to_return(status: 200, body: '{"hello": "world"}', headers: { 'Content-Type' => 'application/json' })

    allow(FastlaneCore::UI).to receive(:message).and_call_original
    expect(FastlaneCore::UI).to receive(:message).with(/Response body:/).at_least(:once)

    Fastlane::Actions::HttpRequestAction.run(url: url, method: "GET", verbose: true)
  end
end
