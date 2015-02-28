class Follow < Socialization::ActiveRecordStores::Follow
	default_scope -> { order('created_at DESC') }
	include PublicActivity::Common
end
