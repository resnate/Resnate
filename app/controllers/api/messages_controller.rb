class API::MessagesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access, :except => :userSearch

  require 'houston'

  def new
    @user = User.find(params[:user])
    @message = current_user.messages.new
  end
 
  def create
  	@recipients = []
  	attrs = params[:user].split(',').each do |attri|
  		@recipients.push(User.find(attri))
  	end

    @sender = params["sender_id"]
    
    User.find(@sender).send_message(@recipients, params[:body], params[:subject])
    @recipients.each do |recipient|
      Pusher.trigger('messages', 'inbox', { message: recipient.id, sender: @sender })
    end
  end

  def index
    userID = APIKey.find_by_access_token(params[:token]).user_id
    current_user = User.find(userID)
    @messages = []
    if current_user.mailbox.conversations.count == 0
      @messages = nil
    else
      conversations = current_user.mailbox.conversations
      conversations.each do |convo|
        if convo.subject[1] == "#"
          receipts = convo.receipts_for current_user
          receipts.each do |receipt|
            message = receipt.message
            #unless message.subject[0] == 'R' && Review.where(id: message.subject[2..-1]).count == 0
            @messages.push(message: message, participants: convo.participants)
          end
        end
      end
      paginate json: @messages, page: params[:page], per_page: 3
    end
  end

  def notifications
    userID = APIKey.find_by_access_token(params[:token]).user_id
    current_user = User.find(userID)
    @messages = []
    if current_user.mailbox.conversations.count == 0
      @messages = nil
    else
      conversations = current_user.mailbox.conversations
      conversations.each do |conversation|
        receipts = conversation.receipts_for current_user
        receipts.each do |receipt|
          if receipt.message.subject[1] == "|" && receipt.message.sender_id != current_user.id
            message = receipt.message
            if User.exists?(id: message.sender_id)
              sender = User.find(message.sender_id)
              @messages.push(message: message, sender: sender)
            end
          end
        end
      end
      paginate json: @messages, page: params[:page], per_page: 10
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
