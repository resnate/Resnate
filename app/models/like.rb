class Like < Socialization::ActiveRecordStores::Like
	default_scope -> { order('created_at DESC') }
	include PublicActivity::Common
end
