OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_CONFIG['app_id'], ENV['FB_SECRET'],
  			image_size: 'large',
           scope: 'user_friends,user_likes,email', provider_ignores_state: true,
           callback_path: '/api/auth/facebook/callback',
           #, {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
end