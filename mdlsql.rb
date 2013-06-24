require 'mysql2'


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
	# 	Calls SqlQuery.config to configurate futures queries. 
	# 	@todo Allow many simultaneous configurations. At the moment
	# @!method config()
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

	def update
		query = SqlQuery.new.update()
	  return query
	end


	def config(values={})
		SqlQuery.config(values)
	end

	module_function :config, :select, :insert, :update
	
	class SqlQuery	
		# Public
		# @!method select()
		# @!method column()
		# @!method from()
		# @!method where()
		# @!method execute()

		# Private
		# @!method select_ex()
		# @!method insert_ex() 
		# 	@note Still not implemented.
		# @!method update_ex()
		# 	@note Still not implemented.




	  def initialize
	    # Initializes query as a string
	    #   @return self [SqlQuery] so other methods may be concatenated.
			# @where = Array.new
			return self
	  end

	  def self.config(values={})
	  	@@host = values[:host]
			@@username = values[:username]
			@@password = values[:password]
			@@db = values[:database]
			@@socket = values[:socket]

			if values[:parse] == :yml || values[:parse] == :yaml
				if values[:file]
					if File.exists?	values[:file]
						YAML.load(File.read(values[:file]))
					else
						raise FileNotFound, "Config file was not found. Parsing could not take place."
					end	
				else
					raise ArgumentError, "File value missing, config file could not be parsed."
				end
			end
		end
	  
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

	  def update()
	  	@method = :update
			return self
	  end
	  
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
			# @note use into() when inserting for readability.
			#	@return (@see initialize)
			table = table.to_sym if table.is_a? String
			table_alias = table_alias if table_alias.is_a? String

			@from = table
			@from_alias = table_alias unless table_alias.nil?
			return self
		end

		# alias into() and from() select table 
		alias_method :into, :from
	  

	  def where(first, second=nil, comp=nil)
			# @param first [String, Array] as a string it can be the whole WHERE declaration or just the first element. As an Array, it contains a list of where declarations
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
			@values ||= Array.new

			@values << val

			return self
		end


	  def execute
		# TODO config for different db
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
			query = self.send("#{@method}_#{@@socket}")


			@result = client.query query
			return @result
			# return query
		end

		private

		def select_mysql()
			query = String.new
			query = "SELECT"

			# Columns (with alias)
			if @cols	
				@cols.each do |key,value|
					query << " #{value} AS #{key}"
				end
			else
				query << " *"
			end
			
			# From (with possible alias)
			if @from
				query << " FROM #{@from}"
				query << " AS #{@from_alias}" if @table_alias
			else
				raise "No table at select query."
			end
			
			# @leftjoin = {:tablealias => {:name => "tablename", :on => "oncondition"}...}
			if @leftjoin && @leftjoin.length > 0
				@leftjoin.each do |key, value|
					query << " LEFT JOIN #{value[:name]} AS #{key} ON #{value[:on]}"
				end
			end
			# @where = Array
			if @where && @where.length > 0
				query << " WHERE"
				@where.each do |dec|
					query << " #{dec}"
				end
			end
			puts query
			return query
		end

		def insert_mysql()
			# INSERT INTO table (column1, column2) VALUES (v1c1, v1c2), (v2c1, v2c2)

			query = String.new
			query = 'INSERT INTO'

			if @from
				query << " #{@from}"
			else
				raise "No table at insert query."
			end

			puts @cols.inspect
			if @cols && @cols.count > 0
				query << ' ('
				@cols.each do |key,col|
					query << "#{col},"
				end

				query.chop! << ')'
			end

			query << ' VALUES'

			if @values
				@values.each do |row|
					query << ' ('
					row.each do |val|
						query << "'#{val}'" << ','
					end
					query.chop!
					query << '),'
				end
				query.chop!
			else
				raise 'No values to insert.'
			end

			return query
		end
	end
end
