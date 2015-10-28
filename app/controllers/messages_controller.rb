class MessagesController < ApplicationController
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
    end
  end
end
