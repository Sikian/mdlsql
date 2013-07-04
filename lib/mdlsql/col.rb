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
	class Col
		# @!attribute table [Table]
		# @!attribute col [Symbol]
		attr_accessor :table, :col

		# @param table [Table]
		# @param col [Symbol]
		def initialize col, table
			# table = table.to_sym if table.is_a? String
			col = col.to_sym if col.is_a? String

			@table = table
			@col = col
		end
	end
end