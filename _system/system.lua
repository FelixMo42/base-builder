class = {}

function class:new(this)
	local this = this or {}
	for k in pairs(self) do
		if not this[k] then
			this[k] = self[k]
		end
	end
	if this.load then
		this:load(self)
	end
	return this
end

function class:tableCopyLoad(o)
	for k, v in pairs(o) do
		if type(v) == "table" and self[k] == o[k] then
			self[k] = table.copy(v)
		end
	end
end

function class:tableDeepCopyLoad(o)
	for k, v in pairs(o) do
		if type(v) == "table" then
			self[k] = table.deepCopy(v)
		end
	end
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

path = {}

function path.find(start,target,map,targetOk)
	if targetOK == nil then
		local targetOK = true
	end
	local open = {}
	local closed = {}
	open[start.x.."_"..start.y] = start:new()
	open[start.x.."_"..start.y].g = 0 --dist from start
	open[start.x.."_"..start.y].h = math.floor(math.sqrt((start.x-target.x)^2+(start.y-target.y)^2)*10)/10 --dist from end
	open[start.x.."_"..start.y].f = open[start.x.."_"..start.y].h --G+H
	local current = nil
	while true do
		for n in pairs(open) do
			if not current or current.f > open[n].f then
				current = open[n]
			end
		end
		if not current or closed[target.x.."_"..target.y] then
			break
		end
		open[current.x.."_"..current.y] = nil
		closed[current.x.."_"..current.y] = current
		local n = {}
		for x = current.x-1,current.x+1 do
			for y = current.y-1,current.y+1 do
				if x ~= current.x and  y ~= current.y and map:tileWalkeble(x,current.y) and map:tileWalkeble(current.x,y) then
					n[#n+1] = vector2:new(x,y) 
					n[#n].g = current.g + 14
					n[#n].h = math.floor(math.sqrt((x-target.x)^2+(y-target.y)^2)*10)
					n[#n].f = n[#n].g + n[#n].h
					n[#n].p = current
				elseif (x ~= current.x and y == current.y) or (x == current.x and  y ~= current.y) then
					n[#n+1] = vector2:new(x,y)
					n[#n].g = current.g + 10
					n[#n].h = math.floor(math.sqrt((x-target.x)^2+(y-target.y)^2)*10)
					n[#n].f = n[#n].g + n[#n].h
					n[#n].p = current
				end
			end
		end
		for i = 1,#n do
			if (not closed[n[i].x.."_"..n[i].y] and map:tileWalkeble(n[i].x,n[i].y)) or (n[i].x == target.x and n[i].y == target.y) then
				if not open[n[i].x.."_"..n[i].y] or open[n[i].x.."_"..n[i].y].f > n[i].f then
					open[n[i].x.."_"..n[i].y] = n[i]
				end
			end
		end
		n = nil
		current = nil
	end
	local path = {}
	local s = true
	if closed[target.x.."_"..target.y] then
		path[1] = closed[target.x.."_"..target.y]
		while path[#path].g ~= 0 do
			path[#path+1] = path[#path].p
		end
	else
		path[1] = start[start.x.."_"..start.y]
		s = false
	end
	return path,s,closed,open
end

function path.loop(f,t)
	local t = t or 10
	for n = 1,t do
		for i = 1, 2*n-1 do
			if f(-n+1,-n+1+i) then
				return -n+1, -n+1+i
			end
		end
		for i = 1, 2*n-1 do
			if f(-n+1+i,n) then
				return -n+1+i, n
			end
		end
		for i = 1, 2*n do
			if f(n,n-i) then
				return n, n-i
			end
		end
		for i = 1, 2*n do
			if f(n-i,-n) then
				return n-i, -n
			end
		end
	end
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

function table.copy(t)
	local nt = {}
	for k,v in pairs(t) do
		nt[k] = v
	end
	return nt
end

function table.deepCopy(t)
    local lookup_table = {}
    local function _copy(t)
        if type(t) ~= "table" then
            return t
        elseif lookup_table[t] then
            return lookup_table[t]
        end
        local new_table = {}
        lookup_table[t] = new_table
        for index, value in pairs(t) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(t))
    end
    return _copy(t)
end

function table.count(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function table.getValue(t)
	for k,v in pairs(t) do
		return v,k
	end
end

function string.lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return "" end
	helper((str:gsub("(.-)\r?\n", helper)))
	return t
end