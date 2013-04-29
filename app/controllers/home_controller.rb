require "market_beat"
require "httparty"
require "nokogiri"
require "open-uri"
require "csv"
require "yahoofinance"

class HomeController < ApplicationController
  include HTTParty
  base_uri "api.bitcoincharts.com"

  def index
    if params[:symbol].nil? || params[:symbol].empty?
      @symbol = "AAPL"
    else
      @symbol = params[:symbol].upcase
    end
    @price = MarketBeat.last_trade_real_time @symbol.to_sym
    #@metal_result = HomeController.get "http://appsrv.cse.cuhk.edu.hk/~rysun/goldprice/"
    #@metal_json = JSON.parse @metal_result.parsed_response
    @bitcoin_result = HomeController.get "http://data.mtgox.com/api/1/BTCUSD/ticker"
    @bitcoin_json = @bitcoin_result.parsed_response
    @coinbul_result = Nokogiri::HTML(open("http://coinabul.com/api.php"))
    @coinbul_json = JSON.parse @coinbul_result.children.text
    @gold_price = @coinbul_json["Gold"]["USD"]
    @silver_price = @coinbul_json["Silver"]["USD"]
    @btc_price = @coinbul_json["BTC"]["USD"]
  end

  def historical
    if params[:symbol].nil? || params[:symbol].empty?
      @symbol = "AAPL"
    else
      @symbol = params[:symbol].upcase
    end
    #this particular file contains monthly gold prices back to 12/31/1978
    text = File.read("#{Rails.root}/app/assets/csvs/monthly_gold_price_USD_1978_2013.csv");
    btc_text = File.read("#{Rails.root}/app/assets/csvs/monthly_btc_price.csv");
    @gold_prices = CSV.parse text
    btc_prices = CSV.parse btc_text
    @coinbul_result = Nokogiri::HTML(open("http://coinabul.com/api.php"))
    @coinbul_json = JSON.parse @coinbul_result.children.text
    #for the current month we will start just using the current price
    @current_gold_price = @coinbul_json["Gold"]["USD"]

    @one_year_gold_prices = []
    @gold_price_array = []
    month_array = []
    year_array = []
    #We will start with just a 1 year historic chart
    @gold_prices[(@gold_prices.length-11)..@gold_prices.length].each do |gp|
      month_hash = {}
      month_hash['month'] = gp[0].split("/")[0]
      if month_hash['month'].length == 1
        #add a leading zero if it is a single digit month
        month_array << "0" + month_hash['month']
      else
        month_array << month_hash['month']
      end
      month_hash['year'] = gp[0].split("/").last
      year_array << month_hash['year']
      month_hash['price'] = ("%.2f" % gp[1].to_f).to_f
      @one_year_gold_prices << month_hash
      @gold_price_array << month_hash['price']
    end
    month_hash = {}
    month_hash['month'] = Date.today.month.to_s
    if month_hash['month'].length == 1
      month_array << "0" + month_hash['month']
    else
      month_array << month_hash['month']
    end
    month_hash['year'] = Date.today.year.to_s
    year_array << month_hash['year']
    month_hash['price'] = ("%.2f" % @current_gold_price.to_f).to_f
    @one_year_gold_prices << month_hash
    @gold_price_array << month_hash['price']
    @gold_price_data = []
    @gold_price_array.each do |p|
      index = @gold_price_array.index(p)
      @gold_price_data << [index, p]
    end

    gold_btc_array = []
    btc_prices[btc_prices.length-11..btc_prices.length].each do |b|
      btc_price_array << ("%.2f" % b[1].to_f).to_f
    end

    #Get bitcoin prices for last year
    last_year = (Date.today - 365).to_time.to_i
    btcdoc = Nokogiri::HTML(open("http://bitcoincharts.com/t/trades.csv?symbol=mtgoxUSD&start=#{last_year}"))
    btccsv=CSV.parse btcdoc.text
    btc_price_array = []
    month_index = 0
    btc_month = month_array[0]
    prev_btc_month = month_array[0]
    btccsv.each do |b|
      btc_index = btccsv.index(b)
      btc_month = Time.at(b[0].to_i).month.to_s
      
      if btc_month.length == 1
        btc_month = "0" + btc_month
      end

      if btc_month == !month_array[month_index]
        if prev_btc_month == month_array
          #store the last price from the month in the btc_price_array
          btc_price_array << btccsv[btc_index - 1][1]
          month_index += 1
        end
      end
      prev_btc_month = btc_month
    end
    #for the current month use the last price
    btc_price_array << btccsv.last[1]

    symbol_data = YahooFinance::get_historical_quotes_days(@symbol,365).reverse
    symbol_gold_price_array = []
    symbol_btc_price_array = []
    @symbol_gold_data = []
    @symbol_btc_data = []
    @xticks = []
    @xtick_index = []
    @xtick_date = []
    symbol_data.each do |d|
      symbol_index = symbol_data.index(d)
      month = d[0].split("-")[1]
      year = d[0].split("-")[0]
      index = month_array.index(month)
      if symbol_index > 0 && month != symbol_data[symbol_index-1][0].split("-")[1]
        @xticks << [symbol_index, month.to_i]
        @xtick_index << symbol_index
        @xtick_date << "#{month}/#{year}"
      end
      symbol_gold_price = ("%.4f" % (d[4].to_f/@gold_price_array[index].to_f)).to_f
      symbol_btc_price = ("%.4f" % (d[4].to_f/btc_price_array[index].to_f)).to_f
      @symbol_gold_data << [symbol_index, symbol_gold_price]
      @symbol_btc_data << [symbol_index, symbol_btc_price]
    end

  end
end
