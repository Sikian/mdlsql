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
	class Table
		attr_accessor :name, :as
		def initialize name, as=nil

			if name.is_a? String
				name = name.to_sym
			elsif name.is_a? Hash
				name = name.flatten

				if name[1].is_a? String
					as = name[1].to_sym
				else
					as = name[1]
				end

				if name[0].is_a? String
					name = name[0].to_sym
				else
					name = name[0]
				end
			end

			as = as.to_sym if as.is_a? String

			@name = name
			@as = as if as
		end

		def to_mysql
			s = String.new
			s << @name.to_s
			s << ' AS ' << @as.to_s if @as
			return s
		end
	end
end