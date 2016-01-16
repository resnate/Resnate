Gibbon::Request.api_key = ENV["MAILCHIMP_API_KEY"]
Gibbon::Request.timeout = 15
Gibbon::Request.throws_exceptions = true
puts "MailChimp API key: #{Gibbon::Request.api_key}" # temporary