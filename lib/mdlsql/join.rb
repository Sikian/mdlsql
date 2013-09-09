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
	class Join
		# @!attribute type [Symbol]
		# @!attribute table [Table]
		# @!attribute col1 [Symbol/String]
		# @!attribute col2 [Symbol/String]
		# @!attribute op [Symbol]

		attr_accessor :type, :table, :cond1, :cond2, :op

		def initialize opts={}
			@cond1 = opts[:cond1]
			@cond2 = opts[:cond2]
			@table = Table.new opts[:table]
			@type = opts[:type]

			opts[:op].to_sym if opts[:op].is_a? String
			@op = opts[:op]
			@op ||= '='.to_sym
		end

		# Literals must be made explicit with apostrophes.
		def to_mysql
			# query = String.new
			query = "\n"
			query << @type.to_s.upcase << ' ' if @type
			query << 'JOIN'
			query << " " << @table.to_mysql
			query << "\nON #{@cond1} #{@op} #{@cond2}"
			return query
		end
	end
end