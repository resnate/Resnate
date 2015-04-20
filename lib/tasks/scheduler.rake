task :remove_old => :environment do
	Gig.all.each do |gig|
			if gig.gig_date.to_date < Date.today
				skID = gig.songkick_id
				uid = gig.user_id
				date = gig.gig_date
				pg = PastGig.build(past_gig: { songkick_id: skID, user_id: uid, gig_date: date })
				pg.save!
				gig.destroy
			end
		end
end