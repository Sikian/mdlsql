require 'mysql2'
require_relative './sockets/mysql.rb'
require_relative './sqlquery.rb'

###
# Modular Sql (queries)
#
# Modular Sql is a modular query builder that enables a high database compatibility, usage 
# easiness and dynamic construction. It is intended to allow any kind of query in any database,
# but will, at the moment, only handle relatively simple ones to most common databases.
#
# This api was initially intended for Bionline (http://bion-line.com).
# 
# Output is given as a MysqlResult object, more info @ https://github.com/brianmario/mysql2#usage
# @author Sebastián (Sikian) Neira Farriol, <sikian@gmail.com>
# @version 0.1
#
# @example Simple select
# 	result = Array.new
# 	result = MdlSql::select.from(:users).where(:id, 1, '=').execute
#
# @example Simple insert
#  	result = MdlSql::insert.into(:users).cols(:user, :role).values('admin',2).execute

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
