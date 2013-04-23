require "market_beat"
require "httparty"

class HomeController < ApplicationController
  include HTTParty
  base_uri "api.bitcoincharts.com"

  def index
    if params[:symbol].nil? || params[:symbol].empty?
      @symbol = "AAPL"
    else
      @symbol = params[:symbol]
    end
    @price = MarketBeat.opening_price @symbol.to_sym
    #@metal_result = HomeController.get "http://appsrv.cse.cuhk.edu.hk/~rysun/goldprice/"
    #@metal_json = JSON.parse @metal_result.parsed_response
    @bitcoin_result = HomeController.get "http://data.mtgox.com/api/1/BTCUSD/ticker"
    @bitcoin_json = @bitcoin_result.parsed_response
    @coinbul_result = HomeController.get "http://coinabul.com/api.php"
    @coinbul_json = JSON.parse @coinbul_result.parsed_response
    @gold_price = @coinbul_json["Gold"]["USD"]
    @silver_price = @coinbul_json["Silver"]["USD"]
    @btc_price = @coinbul_json["BTC"]["USD"]
  end
end
