path = File.dirname(__FILE__) + "/mdlsql/"

[
 	"version"
	"sqlquery",

	"sockets/mysql"
].each do |library|
	require path + library
	puts path + library
end

module MdlSql
  # @!method select()
	# @!method insert()
	# @!method update()
	# @!method config()
	# 	Calls SqlQuery.config to configurate futures queries. 
	# 	@todo Allow many simultaneous configurations. For the moment being, use different config files.
	# 	@option values [Symbol]
	
	# module_function :select, :insert, :update, :config

	@host = String.new

	def select()
	  query = SqlQuery.new.select()
	  return query
	end

	def insert
		query = SqlQuery.new.insert()
	  return query
	end

	def update(table=nil)
		query = SqlQuery.new.update(table)
	  return query
	end

	def config(values={})
		SqlQuery.config(values)
	end

	module_function :config, :select, :insert, :update
end
