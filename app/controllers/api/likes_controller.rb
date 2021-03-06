class API::LikesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  #before_filter :restrict_access

  def create
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @likeable_type = params[:likeable_type]
    @likeable_id = params[:likeable_id]
    if @likeable_type == "Song"
      @liked = Song.find(@likeable_id)
    elsif @likeable_type == "Gig"
      @liked = Gig.find(@likeable_id)
    elsif @likeable_type == "Review"
      @liked = Review.find(@likeable_id)
    end
      @user.like!(@liked)
      @like = Like.where(liker_id: @user.id, likeable_type: @likeable_type).find_by_likeable_id(@liked.id)
      @like.create_activity :create, owner: @user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first.id
      @message = @activity.to_s + ',' + @user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
      listener = User.find(@liked.user_id)
      if @user != listener
        lv1 = listener.level
        if @likeable_type == "Song"
          listener.add_points(1)
          @user.send_message(listener, "test", "S|"+ @likeable_id.to_s)
          Pusher.trigger('messages', 'inbox', { message: listener.id, sender: @user })
          if listener.device_token
            token = listener.device_token
            notification = Houston::Notification.new(device: token)
            notification.alert = current_user.name + " liked " + Song.find(PublicActivity::Activity.find(params[:body]).trackable_id).name
            notification.sound = "sosumi.aiff"
            notification.badge = listener.mailbox.receipts.where(is_read:false ).count
            APN.push(notification)
          end
        elsif @likeable_type == "Gig"
          listener.add_points(5)
          @user.send_message(listener, "test", "G|"+ @likeable_id.to_s)
          Pusher.trigger('messages', 'inbox', { message: listener.id, sender: @user })
          if listener.device_token
            token = listener.device_token
            notification = Houston::Notification.new(device: token)
            notification.alert = current_user.name + " liked one of your upcoming gigs!"
            notification.sound = "sosumi.aiff"
            notification.badge = listener.mailbox.receipts.where(is_read:false ).count
            APN.push(notification)
          end
        elsif @likeable_type == "Review"
          listener.add_points(5)
          @user.send_message(listener, "test", "R|"+ @likeable_id.to_s)
          Pusher.trigger('messages', 'inbox', { message: listener.id, sender: @user })
          if listener.device_token
            token = listener.device_token
            notification = Houston::Notification.new(device: token)
            notification.alert = current_user.name + " liked a review you wrote!"
            notification.sound = "sosumi.aiff"
            notification.badge = listener.mailbox.receipts.where(is_read:false ).count
            APN.push(notification)
          end
        end
        lv2 = listener.level
        if lv1 != lv2
          listener.create_activity key: 'badge.create', parameters: {level: listener.level}, owner: listener
          User.find(3).send_message(listener, "New level: "+ listener.level_name, "B|"+ listener.level_name)
          listener.add_badge(listener.level)
          badgeActivity = PublicActivity::Activity.where(key: "badge.create", owner: listener).last.id
          badgeMessage = badgeActivity + ',' + @user.uid.to_s
          Pusher.trigger('activities', 'feed', {:message => badgeMessage})
          Pusher.trigger('messages', 'inbox', { message: listener.id, sender: @user })
          if listener.device_token
            token = listener.device_token
            notification = Houston::Notification.new(device: token)
            notification.alert = "New level: "+ listener.level_name
            notification.sound = "sosumi.aiff"
            notification.badge = listener.mailbox.receipts.where(is_read:false ).count
            APN.push(notification)
          end
        end
      end
    
  end

  def destroy
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @likeable_type = params[:likeable_type]
    if @likeable_type == "Song"

      @content = Song.find(params[:likeable_id]).content
      @songs = Song.where(content: (@content))
      likee = User.find(Song.find(params[:likeable_id]).user_id)

      if likee != @user
        lv1 = likee.level
        likee.subtract_points(1)
        lv2 = likee.level
        if lv1 != lv2
          likee.rm_badge(lv1)
        end
      end

      @songs.each do |song|
        if @user.likes?(song)
          @like = Like.where(likeable_type: "Song", likeable_id: song.id).first
          @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first
          @activity.destroy
          @user.unlike!(song)
        end
      end
    elsif @likeable_type == "Review"
      review = Review.find(params[:likeable_id])
      likee = User.find(review)
      if likee != @user
        lv1 = likee.level
        likee.subtract_points(1)
        lv2 = likee.level
        if lv1 != lv2
          likee.rm_badge(lv1)
        end
      end
      @like = Like.where(likeable_type: "Review", likeable_id: params[:likeable_id]).first
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first
      unless @activity.nil?
        @activity.destroy
      end
      @user.unlike!(review)
    end
    render nothing: true
  end

  def show
    @like =  Like.find(params[:id])
  end

  def ifLike
    @user = User.find(params[:liker_id])
    if params[:likeable_type] == "Song"
      content = Song.find(params[:likeable_id]).content
      songs = Song.where(content: content)
      @count = 0
      songs.each do |song|
        if @user.likes?(song)
          @count += 1
        end
      end
    elsif params[:likeable_type] == "Gig"
      songkickID = Gig.find(params[:likeable_id]).songkick_id
      gigs = Gig.where(songkick_id: songkickID)
      @count = 0
      gigs.each do |gig|
        if @user.likes?(gig)
          @count += 1
        end
      end
    elsif params[:likeable_type] == "Review"
      review = Review.find(params[:likeable_id])
      @count = 0
      if @user.likes?(review)
        @count += 1
      end
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