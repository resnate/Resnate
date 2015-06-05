task :remove_old => :environment do
	Gig.all.each do |gig|
			if gig.gig_date.to_date < Date.today
				skID = gig.songkick_id
				uid = gig.user_id
				date = gig.gig_date

				if User.find(uid).past_gigs.find_by_songkick_id(skID).nil?
					pg = User.find(uid).past_gigs.build({ songkick_id: skID, user_id: uid, gig_date: date })
					pg.save!
				end
				
				PublicActivity::Activity.where(trackable_id: gig.id, trackable_type: "Gig").first.destroy!
				gig.destroy!
				puts "seek and destroy"
			end
		end
end