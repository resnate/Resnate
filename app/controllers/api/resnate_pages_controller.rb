class API::ResnatePagesController < ApplicationController
  	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_filter :restrict_access, :except => :userSearch

	def AmazonStore
		@user = User.find(params[:id])
    	if @user.country == "United Kingdom"
      		req = Vacuum.new('GB', true)
    	elsif @user.country == "France"
      		req = Vacuum.new('FR', true)
    	else
      		req = Vacuum.new('US', true)
    	end
    	search_query = params[:search_query]
  		req.associate_tag = 'resnate-21'
            req.configure(   aws_access_key_id:     ENV['S3_KEY'],aws_secret_access_key: ENV['S3_SECRET'], associate_tag: 'resnate-21')
             params = {'SearchIndex' => 'Apparel', 'Keywords'    => search_query, 'ResponseGroup' => 'ItemAttributes, Offers, Images', 'Availability' => "Available", 'Condition' => "All", 'ItemPage' => 1} 
             res = req.item_search(params)
             hash = res.to_h
             puts hash
             items = hash["ItemSearchResponse"]["Items"]["Item"]
             noOfItems = Integer(hash["ItemSearchResponse"]["Items"]["TotalResults"])
              if noOfItems == 0
                @results = nil
              elsif noOfItems == 1
                @results = []
              @results.push :image => 'https://d1ge0kk1l5kms0.cloudfront.net/images/I/' + items["LargeImage"]["URL"][38..-1], :link => items["DetailPageURL"].insert(4, 's')
              else
             	  @results = []
                items.first(3).each do |i|
                  if i["LargeImage"].nil?
                    next
                  else
                    @results.push :image => 'https://d1ge0kk1l5kms0.cloudfront.net/images/I/' + i["LargeImage"]["URL"][38..-1], :link => i["DetailPageURL"].insert(4, 'S')
					
                  end
              end
            
        end
        unless @results.nil?
          paginate json: @results, per_page: 3
        end
  	end

	private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          APIKey.exists?(access_token: token)
        end

        def request_http_token_authentication(realm = "Application")  
          self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
          self.__send__ :render, :json => { :error => "HTTP Token: Access denied. You did not provide an valid API key." }.to_json, :status => :unauthorized
        end
      end
end