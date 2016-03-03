require 'houston'

APN = Houston::Client.development
APN.certificate = ENV["APPLE_DEV_PEM"]

puts APN