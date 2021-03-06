jQuery ->

  $.ajax
    url: "#{window.location.protocol}//connect.facebook.net/en_US/all.js"
    dataType: 'script'
    cache: true


window.fbAsyncInit = ->
  FB.init(appId: '397688387002984', cookie: true)

  $('#sign_in').click (e) ->
    e.preventDefault()
    FB.login ((response) ->
    	window.location = '/auth/facebook/callback' if response.authResponse), scope: "user_friends,user_likes,email"

  $('#sign_out').click (e) ->
    FB.getLoginStatus (response) ->
      FB.logout() if response.authResponse
    true