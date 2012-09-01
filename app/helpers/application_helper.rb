# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def set_body_class
    class_name = mobile_device? ? "mobile" : "full"
    class_name
  end

  def rand_code(limit)
    str1 = ("a".."z").to_a + ("0".."9").to_a
    arr1 = []
    (1..limit).each { |i| arr1 << str1[rand(999)%str1.length] }
    return arr1.to_s
  end

  def plural(num, text)
    pluralize(num, text)
  end

  def nights_options
    opts = []
    (1..2).each do |i|
      opts.push([plural(i,"Night"),i])
    end
    opts
  end

  def to_currency(number, options = {})
    return number_to_currency(number, options)
  end

  def check_in_datetime(today)
#    if today.hour > 0 and today.hour <= 6
#      today = today
#    elsif today.hour > 6
#       today += 1
#    end
    return today
  end
  
  def check_in_text(today)
    text = nil
    if today.hour > 0 and today.hour <= 6
       text = "Immediately"
       text = "4pm Guaranteed" if today.hour == 6 and today.min > 0
    elsif today.hour > 6
      text = "4pm Guaranteed"
    end
    return text
  end

  def check_out_datetime(today)
#    if today.hour > 0 and today.hour <= 6
#       today += 1 if today.hour == 6 and today.min > 0
#    elsif today.hour > 6
#        today += 1
#    end
    if today.hour >= 12
       today += 1
    end
    return today
  end

  def can_booking?
    today = Time.now.in_time_zone("Eastern Time (US & Canada)").to_datetime - 10.hours
    if today.hour >=3 and today.hour < 12
      return false
    else
      return true
    end
  end

  def left_time_in_seconds
    today = Time.now.in_time_zone("Eastern Time (US & Canada)")  
    start_time = today.beginning_of_day + 12.hours    
    diff = start_time - today
    diff
  end

  def datetime_format(datetime)
    return nil if datetime.nil?
    format = datetime.strftime("%m-%d-%Y %H:%M")
    format
  end
  
  def date_format(datetime)
    return nil if datetime.nil?
    format = datetime.strftime("%m-%d-%Y")
    format
  end

  def with_delimiter(number, options = {})
    return number_with_delimiter(number, options)
  end
  def analytics_details(from, to)
    gs = Gattica.new({:email => 'dealkat@gmail.com', :password => "princessthecat", :profile_id => 61710247})
    results = gs.get({:start_date => from.to_s, :end_date => to.to_s,
                :dimensions => ['medium', 'source'], :metrics => ['pageviews', 'visits', 'timeOnSite'], :sort => '-pageviews'})
    @xml_data = results.to_xml
    @data = Hpricot::XML(@xml_data)
    analytics = {}
    (@data/'dxp:aggregates').each do |aggregate|
      (aggregate/'dxp:metric').each do |metric|
          analytics["pageviews"] = metric[:value] if metric[:name] == "ga:pageviews"
          analytics["visits"] = metric[:value] if metric[:name] == "ga:visits"
          analytics["timeOnSite"] = metric[:value] if metric[:name] == "ga:timeOnSite"
      end
    end
    return analytics
  end
  
end
