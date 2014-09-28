class MessagesController < ApplicationController
  def new
    @user = User.find(params[:user])
    @message = current_user.messages.new
  end
 
  def create
  	@recipient = []
  	attrs = params[:user].split(',').each do |attri|
  		@recipient.push(User.find(attri))
  	end
    
    current_user.send_message(@recipient, params[:body], params[:subject])
  end
end
