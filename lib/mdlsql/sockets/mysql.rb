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

class QueryBuilder
	def select; end
	def insert; end
	def update; end
end

class MysqlBuilder < QueryBuilder
	def initialize
	end

	class << self
		def select(values={})
			cols = values[:cols]
			tables = values[:tables]
			where = values[:where]
			join = values[:join]

			query = String.new
			query = "SELECT"

			# Columns (with alias)
			if cols	
				cols.each do |key,value|
					query << " #{value} AS #{key}"
				end
			else
				query << " *"
			end
			
			# From (with possible alias)
			if tables
				query << ' FROM'
				tables.each do |tab|
					query << ' ' << tab.to_mysql
					# query << " #{tab.name}"
					# query << " AS #{tab.as}" if tab.as
					query << ","
				end
				query.chop!

			else
				raise "No table at select query."
			end
			
			# @join, see Join
			if join && join.length > 0
				join.each do |j|
					query << j.to_mysql
					# query << ' ' << value[:type] if value[:type]
					# query << ' ' << value[:table].to_s
					# query << " ON #{value[:cond1]} #{value[:op]} #{value[:cond2]}"
				end
			end
			# @where = Array
			if where && where.length > 0
				query << "\nWHERE"
				# where.each do |dec|
				# 	query << " #{dec}"
				# end
				first = true
				where.each do |wh|
					query << " #{wh.concat}" unless first
					query << " #{wh.cond1} #{wh.op} #{wh.cond2}"
					first = false
				end
			end

			return query
		end

		def insert(values={})
			# INSERT INTO table (column1, column2) VALUES (v1c1, v1c2), (v2c1, v2c2)

			query = String.new
			query = 'INSERT INTO'

			if @from
				query << " #{@from}"
			else
				raise "No table at insert query."
			end

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

		def update(values={})
			# UPDATE example SET age='22' WHERE age='21'

			table = values[:table]
			set = values[:values]
			where = values[:where]

			query = String.new()

			if table
				query << "UPDATE #{table} "
			else
				raise "No table at update query."
			end

			query << 'SET'

			if set && set.count > 0
				set.each do |key, value|
					query << " #{key} = '#{value}',"
				end
				query.chop!
			else
				raise 'Nothing to be set.'
			end

			query << ' WHERE'

			if where && where.count > 0
				where.each do |con|
					query << ' ' << con << ','
				end
				query.chop!
			else
				raise 'No WHERE condition in update.'
			end

			return query
		end
	end
end