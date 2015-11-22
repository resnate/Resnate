# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongo_mapper and :mongoid
  # config.orm = :active_record

  # Define :user_model_name. This model will be used to grand badge if no :to option is given. Default is "User".
  # config.user_model_name = "User"

  # Define :current_user_method. Similar to previous option. It will be used to retrieve :user_model_name object if no :to option is given. Default is "current_#{user_model_name.downcase}".
  # config.current_user_method = "current_user"
end

Merit::Badge.create!(
   id: 1,
   name: 'Hipster',
   level: 1,
   description: "You knew <insertbandhere> before they were cool/popular/famous.",
   custom_fields: { image: "HipsterGlasses.png"}
)

Merit::Badge.create!(id: 2,
   name: 'UberHipster',
   level: 2,
   description: "You only listen to music on 8-tracks, vinyl is way too mainstream.",
   custom_fields: { image: "UberHipsterTache.png"})

Merit::Badge.create!(id: 3,
   name: 'Groupie',
   level: 3,
   description: "You'll do anything to see your favourite artist backstage.",
   custom_fields: { image: "Groupie.png"})

Merit::Badge.create!(id: 4,
   name: 'SuperGroupie',
   level: 4,
   description: "Your favourite artist has you on speed dial when they're in town.",
   custom_fields: { image: "badge_7.png"})

Merit::Badge.create!(id: 5,
   name: 'Rock Star',
   level: 5,
   description: "Now you've got your own groupies.",
   custom_fields: { image: "badge_8.png"})

Merit::Badge.create!(id: 6,
   name: 'Rap God',
   level: 6,
   description: "You have become worthy of worship.",
   custom_fields: { image: "badge_9.png"})

Merit::Badge.create!(id: 7,
   name: 'BIGGER THAN JESUS',
   level: 7,
   description: "The Beatles have nothing on you.",
   custom_fields: { image: "badge_10.png"})
