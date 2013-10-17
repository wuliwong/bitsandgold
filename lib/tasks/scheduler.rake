desc "This task is called by Heroku scheduler add-on"
task :update_monthly_prices => :environment do
  require "nokogiri"
  require "open-uri"
  require "csv"
  today = Date.today

  #only run on the last hour of the last day of the month
  if today.month == today.next_day.month
    if Time.now.hour == 18
      coinbul_result = Nokogiri::HTML(open("http://coinabul.com/api.php"))
      coinbul_json = JSON.parse coinbul_result.children.text
      gold_price = coinbul_json["Gold"]["USD"]
      silver_price = coinbul_json["Silver"]["USD"]
      btc_price = coinbul_json["BTC"]["USD"]

      gold_file = File.read("#{Rails.root}/app/assets/csvs/monthly_gold_price_USD_1978_2013.csv")
      gold_csv = CSV.parse gold_file
      btc_file = File.read("#{Rails.root}/app/assets/csvs/monthly_btc_price.csv")
      btc_csv = CSV.parse btc_file

      date_string = today.month.to_s + "/"  + today.day.to_s + "/"+ today.year.to_s

      CSV.open("#{Rails.root}/app/assets/csvs/monthly_btc_price.csv","a") do |csv|
        csv.add_row([date_string, btc_price])
      end

      CSV.open("#{Rails.root}/app/assets/csvs/monthly_gold_price_USD_1978_2013.csv","a") do |csv|
        csv.add_row([date_string, gold_price])
      end

    end
  end
end