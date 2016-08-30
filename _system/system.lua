class = {}

function class:new(this)
	local this = this or {}
	setmetatable(this, self)
	self.__index = self
	if this.load then
		this:load(self)
	end
	return this
end

vector2 = {}

function vector2:new(x,y)
	local this = {x = x, y = y}
	for k in pairs(self) do
		this[k] = self[k]
	end
	if this.load then
		this:load()
	end
	return this
end

function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function table.removeValue(t,v)
	for k in pairs(t) do
		if t[k] == v then
			if type(k) == "number" then
				table.remove(t,k)
			else
				t[k] = nil
			end
		end 
	end
end

function table.count(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function table.copy(object)
	    local lookup_table = {}
	    local function _copy(object)
	        if type(object) ~= "table" then
	            return object
	        elseif lookup_table[object] then
	            return lookup_table[object]
	        end
	        local new_table = {}
	        lookup_table[object] = new_table
	        for index, value in pairs(object) do
	            new_table[_copy(index)] = _copy(value)
	        end
	        return setmetatable(new_table, getmetatable(object))
	    end
	    return _copy(object)
	end