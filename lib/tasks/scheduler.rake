task :remove_old => :environment do
	Gig.all.each do |gig|
			if gig.gig_date.to_date < Date.today
				skID = gig.songkick_id
				uid = gig.user_id
				puts skID + "yes" + uid
			else
				puts skID + "no" + uid
			end
		end
end