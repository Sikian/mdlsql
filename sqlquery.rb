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
			#		@return (@see initialize)
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
	  # 	column / cols
	  # 	from / into
	  # 	where
	  # 	values
	  # 	set
	  #

	  def column(*values)
	  	# @todo check column uniqueness in hash
	  	# @todo revise 
			#	@return (@see initialize)
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

	  def from(table, table_alias=nil)
			# Selects table from which to select (or insert, update) with possible alias.
			# @todo use a hash here to allow many tables (for a select, for example).
			# @note use into() when inserting for readability.
			#	@return (@see initialize)
			table = table.to_sym if table.is_a? String
			table_alias = table_alias if table_alias.is_a? String

			@table = table
			@table_alias = table_alias unless table_alias.nil?
			return self
		end

		# alias into() and from() select table 
		alias_method :into, :from
	  

	  def where(first, second=nil, comp=nil)
			# @param first [String, Array] as a string it can be the whole WHERE declaration or just the first element. As an Array, it contains a list of where declarations
			
			@where ||= Array.new
			if second.nil?
				@where << first
			else
				if comp.nil?
					raise "Don't know which logical operator to use in the where statement."
				else
					@where << "#{first} #{comp} '#{second}'"
				end
			end

			return self
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
		# Exacution command

	  def execute
	 		# @todo return true/false when inserting/updating 
			# @todo config for different db
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