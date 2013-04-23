require "market_beat"
require "httparty"

class HomeController < ApplicationController
  include HTTParty
  base_uri "api.bitcoincharts.com"

  def index
    @price = MarketBeat.opening_price :AAPL
    @bitcoin_json = HomeController.get "http://appsrv.cse.cuhk.edu.hk/~rysun/goldprice/"
    @bitcoin_json = JSON.parse @bitcoin_json.parsed_response
  end
end
