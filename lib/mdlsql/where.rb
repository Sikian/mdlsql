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
	class Where
		# @!attribute col1 [Symbol/String]
		# @!attribute col2 [Symbol/String]
		# @!attribute op [Symbol]

		attr_accessor :cond1, :cond2, :op, :concat

		def initialize opts={}
			@cond1 = opts[:cond1]
			@cond2 = opts[:cond2]

			opts[:op].to_sym if opts[:op].is_a? String
			opts[:concat].to_sym if opts[:concat].is_a? String
			@op = opts[:op]
			@concat = opts[:concat]
		end
	end
end