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
			@@debug = values[:debug]
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

	  	if table.is_a? Symbol
	  		from table => table
	  	elsif table.is_a? String
	  		from table.to_sym => table.to_sym
	  	elsif table.is_a? Hash
	  		from table
	  	end
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
  	# @todo use Col class
		# @return (@see initialize)
	  def columns(*values)
			@cols ||= Hash.new

			# key AS value
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

		alias_method :cols, :columns

		###
		#
		# Selects table from which to select (or insert, update) with possible alias.
		# @todo use a hash here to allow many tables (for a select, for example).
		# @note use from() when selecting & into() when inserting for readability.
		#	@return (@see initialize)
	  def tables(tables = {})
			# table = table.to_sym if table.is_a? String
			# table_alias = table_alias if table_alias.is_a? String

			@tables ||= Array.new
			tables.each do |table_alias,table|
				@tables.push Table.new table, table_alias
			end

			# @table = table
			# @table_alias = table_alias unless table_alias.nil?
			return self
		end

		# alias into() and from() select table 
		alias_method :into, :tables
		alias_method :from, :tables
	  

		# Generates a where clause
		# Maybe it's a good idea to make a Where object.
		#
		# FFS, HAVE A CLEAR IDEA BEFORE WRITING!
		#
		# @option opts [String] :op default is =
		# @option opts [Symbol] :concat AND, OR..., default is AND.
		# @note First where clause's concat is ignored.
		# 
		# @todo Add IN, BETWEEN and LIKE (can be done with actual where).
		def where(cond1, cond2, opts={})
			opts[:op] ||= :'='
			opts[:concat] ||= :AND

			# if cond1.is_a? Hash
			# 	if cond1[:table] && cond1[:col]
			# 		cond1 = Col.new cond[:col], cond[:table]

			@where ||= Array.new
			wh = Where.new(
				:cond1 => cond1,
				:cond2 => cond2,
				:op => opts[:op],
				:concat => opts[:concat]
			)
			@where.push wh

			return self
		end

		# @option opts [Symbol/String] :op
		# @option opts [Symbol] :type
		def join(table, cond1, cond2, opts={})
			@join ||= Array.new

			vars = {
				:table => table, 
				:cond1 => cond1, 
				:cond2 => cond2, 
			}
			vars.merge! opts
			@join.push Join.new vars

			return self
		end

		def leftjoin(table, cond1, cond2, opts={})
			opts.update({:type => :left})
			join(table,cond1,cond2, opts)
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
			if @@host.nil? || @@username.nil? || @@password.nil? || @@db.nil?
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
			end

			query = sock.send("#{@method}", 
				{:tables => @tables, 
					:where => @where, 
					:cols => @cols,
					:values => @values,
					:join => @join}
			)

			puts query if @@debug

			@result = client.query query
			return @result

		end
	end
end


