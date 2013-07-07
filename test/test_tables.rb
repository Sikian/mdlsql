require_relative '../lib/mdlsql'

MdlSql.config({
	:host => 'localhost',
	:username => 'root',
	:password => 'candyholaesternocow',
	:database => 'anvyl'
	})

puts results = MdlSql.select
	.from(:users => :u)
	.join(:jobs, :'u.uid', 'jobs.uid')
	.where(:status, 1, :op => :>)
	.execute
	# .where(:'u.id', 3)
	# 

results.each do |r|
	puts "#{r[:username]} :: #{r[:name]}"
end	
