class Follow < Socialization::ActiveRecordStores::Follow
	default_scope -> { order('created_at DESC') }
	include PublicActivity::Model
tracked owner: ->(controller, model) { controller && controller.current_user }
end
