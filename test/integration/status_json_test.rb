require 'test_helper'

class StatusJsonTest < ActionDispatch::IntegrationTest
  def json_response
    JSON.parse(response.body)
  end

  test "Status API: GET / when all services are up" do
    Ping.create! status: "up", service: "Application", description: "This service is up", last_seen: Time.new(2014, 3, 14, 1, 59, 26).utc
    Ping.create! status: "up", service: "Core API", description: "This service is up", last_seen: Time.new(2014, 2, 7, 1, 8, 28).utc

    get "/", {}, {"Accept" => "application/json"}

    service = json_response["services"].find { |s| s["name"] == "Core API" }

    assert_match "up", json_response["status"]
    assert_match "up", json_response["services"][0]["status"]
    assert_match "This service is up",   json_response["services"][0]["descrption"]
    assert_match "2014-03-14T08:59:26Z", json_response["services"][0]["last_seen"]
  end

  test "Status API: GET / when some of the services are down" do
    Ping.create! status: "down", service: "Application", last_seen: Time.new(2014, 3, 14, 1, 59, 26).utc
    Ping.create! status: "up", service: "Core API", last_seen: Time.new(2014, 2, 7, 1, 8, 28).utc

    get "/", {}, {"Accept" => "application/json"}

    assert_match "partial", json_response["status"]
    assert_match "down",    json_response["services"][0]["status"]
    assert_match "up",      json_response["services"][1]["status"]
  end

  test "Status API: GET / when all of the services are down" do
    Ping.create! status: "down", service: "Application", last_seen: Time.new(2014, 3, 14, 1, 59, 26).utc
    Ping.create! status: "down", service: "Core API", last_seen: Time.new(2014, 2, 7, 1, 8, 28).utc

    get "/", {}, {"Accept" => "application/json"}

    assert_match "down", json_response["status"]
    assert_match "down", json_response["services"][0]["status"]
    assert_match "down", json_response["services"][1]["status"]
  end
end
