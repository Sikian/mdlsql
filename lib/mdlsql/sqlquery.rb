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

require_relative './sockets/mysql.rb'
require 'yaml'

module MdlSql
	class SqlQuery	

	  def initialize
	    # Initializes query as a string
	    #   @return self [SqlQuery] so other methods may be concatenated.
	    
			return self
	  end

	  ###
	  # Configuration
	  #

	  def self.config(values={})
	  	# Does config need to be parsed from a config file?
	  	# @todo check relative paths so file is correctly found.
	  	# 	Maybe should be wise to use full paths.
	  	if values[:parse]
				if values[:parse] == :yml || values[:parse] == :yaml
					if values[:file]
						values = YAML.load_file(values[:file])

						# Convert keys to symbols
						values = values.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
					else
						raise ArgumentError, "File value missing, config file could not be parsed."
					end
				end

			end

			@@host = values[:host]
			@@username = values[:username]
			@@password = values[:password]
			@@db = values[:database]
			@@socket = values[:socket]

			puts values.inspect
		end
	  
		###
		# Method selection:
		# 	select()
		# 	insert()
		# 	update(table=nil)
		#

	  def select()
	    # Sets method to select
			#	@return (@see initialize)
	    @method = :select
			
			return self
	  end

	  def insert()
	  	@method = :insert
			return self
	  end

	  def update(table=nil)
	  	@method = :update
	  	from table if table
			return self
	  end
	  
	  ###
	  # Parameters setting:
	  # 	columns / cols
	  # 	from / into
	  # 	where
	  # 	values
	  # 	set
	  #

  	#	@todo check column uniqueness in hash
  	#	@todo revise 
		# @return (@see initialize)
	  def columns(*values)
			@cols ||= Hash.new


			if values[0].is_a? Hash
				values.each do |val|
					@cols.update(val)
				end
				
			else
				values.each do |val|
					@cols.update({val => val})
				end
			end
			return self
		end

		alias_method :cols, :column

		###
		# @!method table(table, table_alias=nil)
		# 	Selects table from which to select (or insert, update) with possible alias.
		# 	@todo use a hash here to allow many tables (for a select, for example).
		# 	@note use from() when selecting & into() when inserting for readability.
		#		@return (@see initialize)
	  def table(table, table_alias=nil)
			table = table.to_sym if table.is_a? String
			table_alias = table_alias if table_alias.is_a? String

			@table = table
			@table_alias = table_alias unless table_alias.nil?
			return self
		end

		# alias into() and from() select table 
		alias_method :into, :table
		alias_method :from, :table
	  

	 #  def where(first, second=nil, comp=nil)
		# 	# @param first [String, Array] as a string it can be the whole WHERE declaration or just the first element. As an Array, it contains a list of where declarations
			
		# 	@where ||= Array.new
		# 	if second.nil?
		# 		@where << first
		# 	else
		# 		if comp.nil?
		# 			raise "Don't know which logical operator to use in the where statement."
		# 		else
		# 			@where << "#{first} #{comp} '#{second}'"
		# 		end
		# 	end

		# 	return self
		# end

		# Generates a where clause
		#
		# @option opts [Symbol] :table
		# @option opts [Symbol] :as table alias
		# @option opts [String] :operator default is =
		# @option opts [Symbol] :concat AND, OR...
		# 
		# @todo Add IN, BETWEEN and LIKE (can be done with actual where).
		def where(opts={})
		end

		def values(*val)
			if @method == :insert
				@values ||= Array.new

				@values << val
			else
				raise 'Use values() only for #insert.'
			end

			return self
		end

		def set(val={})
			if @method == :update
				@values ||= Hash.new

				@values.update val
			else
				raise 'Use set() only for #update.'
			end

			return self
		end

		###
		# @!method execute()
		# Exacution command
	 	# @todo return true/false when inserting/updating 
		# @todo config for different db
	  def execute
			unless @@host && @@username && @@password && @@db
				raise 'MdlSql has not been correctly configured, please use config() to set host, username, password and db.'
			end
	    client = Mysql2::Client.new(
	    	:host => @host, 
	    	:username => @@username, 
	    	:password => @@password, 
	    	:database => @@db,
				:symbolize_keys => true
			)
			
			query = String.new

			@@socket ||= :mysql

			case @@socket
			when :mysql
				sock = MysqlBuilder
				puts sock.class
			end

			query = sock.send("#{@method}", 
				{:table => @table, 
					:where => @where, 
					:cols => @cols,
					:values => @values
			})


			@result = client.query query
			return @result

		end
	end
end

class Row
	attr_accessor :table, :row
	def initialize table, row
		table = table.to_sym if table.is_a? String
		row = row.to_sym if row.is_a? String

		@table = table
		@row = row
	end
end

class Table
	attr_accessor :name, :as
	def initialize name, as=nil
		name = name.to_sym if name.is_a? String
		as = as.to_sym if as.is_a? String

		@name = name
		@as = as
	end
end