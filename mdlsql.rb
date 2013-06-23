require 'mysql2'


###
# Modular Sql (queries)
#
# Modular Sql api initially intended for Bionline (http://bion-line.com).
# Output is given as a MysqlResult object, more info @ https://github.com/brianmario/mysql2#usage
# @author Sebastián (Sikian) Neira Farriol, <sikian@gmail.com>
# @version 0.1
#
# @example Simple usage
# 	result = Array.new
# 	result = MdlSql::select().from(:users).where(:id, 1, '=').execute()

module MdlSql
	# @!method select()
	# @!method insert()
	# @!method update()
	# @!method config()
	# 	@option values [Symbol]
	
	# module_function :select, :insert, :update, :config

	@host = String.new

	def self.select()
	  query = SqlQuery.new.select()
	  
	  # select_hash.each_pair do |key, val|
	  #   query.as(val, key)
	  # end

	  return query
	end

	def self.insert
		puts 'Inserting'
	end

	def self.update
		puts 'Updating'
	end

	def config(values={})
		SqlQuery.config(values)
	end

	module_function :config
	
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
			@where = Array.new
			return self
	  end

	  def self.config(values={})
	  	@@host = values[:host]
			@@username = values[:username]
			@@password = values[:password]
			@@db = values[:database]

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
	  
	  def column(column, alias_name)
			#		@return (@see initialize)
			@cols ||= Hash.new
			@cols.update({alias_name.to_sym => column})
			return self
		end

	  def from(table, table_alias=nil)
			# 
			#	@return (@see initialize)
			table = table.to_sym if table.is_a? String
			table_alias = table_alias if table_alias.is_a? String

			@from = table
			@from_alias = table_alias unless table_alias.nil?
			return self
		end
	  
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

			case @method
			when :select
				query = select_ex()							
			end

			@result = client.query query
			return @result
			# return client
		end

		private

		def select_ex()
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
				raise "No table at select query"
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
	end
end
