module ResnatePagesHelper
	$:.unshift(File.expand_path('../../lib', __FILE__))
require 'pry'
require 'vacuum'

req = Vacuum.new('GB')
req.associate_tag = 'resnate-21'

req.configure(
    aws_access_key_id:     'AKIAIWWQN3DBHE2VGUSQ',
    aws_secret_access_key: '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',
    associate_tag:         'resnate-21'
)

end
