class MessagesController < ApplicationController
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

    @sender = current_user.id
    
    current_user.send_message(@recipients, params[:body], params[:subject])
    @recipients.each do |recipient|
      Pusher.trigger('messages', 'inbox', { message: recipient.id, sender: @sender})
      if recipient.device_token
        token = recipient.device_token
        notification = Houston::Notification.new(device: token)
        notification.alert = "New message from " + current_user.name
        APN.push(notification)
      end
    end
    render nothing: true
  end
  
end
