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
   name: '5',
   custom_fields: { image: "badge_4.png"}
)

Merit::Badge.create!(id: 2,
   name: '10',
   custom_fields: { image: "badge_5.png"})

Merit::Badge.create!(id: 3,
   name: '25',
   custom_fields: { image: "badge_6.png"})

Merit::Badge.create!(id: 4,
   name: '50',
   custom_fields: { image: "badge_7.png"})

Merit::Badge.create!(id: 5,
   name: '100',
   custom_fields: { image: "badge_8.png"})

Merit::Badge.create!(id: 6,
   name: '500',
   custom_fields: { image: "badge_9.png"})

Merit::Badge.create!(id: 7,
   name: '1000',
   custom_fields: { image: "badge_10.png"})
