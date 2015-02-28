object false

@gigs.keys.each do |key|
  node(key){ @values[key] }
end