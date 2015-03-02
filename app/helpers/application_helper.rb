module ApplicationHelper
	
	def full_title(page_title)
    base_title = "Resnate: Music, Gigs, Merch."
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  	def broadcast(channel, &block)
  		message = {:channel => channel, :data => capture(&block), :ext => {:auth_token => FAYE_TOKEN}}
  		uri = URI.parse("https://www.resnate.com/faye")
  		Net::HTTP.post_form(uri, :message => message.to_json)
	end

end
