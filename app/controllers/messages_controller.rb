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
        if params[:subject][1] == "|"
          if params[:subject][0] == "S"
            notification.alert = current_user.name + " liked " + Song.find(params[:body]).name
          elsif params[:subject][0] == "R"
            notification.alert = current_user.name + " liked a review you wrote!"
          end
        else
          notification.alert = "New message from " + current_user.name + ": " + params[:body]
        end
        notification.sound = "sosumi.aiff"
        notification.badge = recipient.mailbox.receipts.where(is_read:false ).count
        APN.push(notification)
      end
    end
    render nothing: true
  end
  
end
