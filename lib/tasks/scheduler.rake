task :remove_old => :environment do
	Gig.all.each do |gig|
			if gig.gig_date.to_date < Date.today
				skID = gig.songkick_id
				uid = gig.user_id
				puts skID.to_s + "yes" + uid.to_s
			else
				puts skID.to_s + "no" + uid.to_s
			end
		end
end