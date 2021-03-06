# Copyright (C) 2013 All MdlSql contributers

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# In order to contact the author of this gem, please write to sikian@gmail.com.

path = File.dirname(__FILE__) + "/mdlsql/"

[
 	"version",
	"sqlquery",

	"sockets/mysql",

	"table",
	"col",
	"where",
	"join"
].each do |library|
	require path + library
end

require 'yaml'
require 'mysql2'

module MdlSql
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

	def query str
		return SqlQuery.new.query(str)
	end

	# Calls SqlQuery.config to configurate futures queries. 
	# @todo Allow many simultaneous configurations. For the moment being, use different config files.
	# @option values [Symbol]
	def config(values={})
		SqlQuery.config(values)
	end

	module_function :config, :select, :insert, :update, :query
end
