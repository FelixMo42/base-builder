itemManeger = class:new({map=map})

function itemManeger:addItem(tile)
	if not self[tile.item.name] then
		self[tile.item.name] = {} 
	end
	self[tile.item.name][tile] = vec2:new(tile.x,tile.y)
end

function itemManeger:remouveItem(tile)
	self[tile.item.name][tile] = nil
end

function itemManeger:findItem(item,x,y)
	if self[item] and table.count(self[item]) > 0 then
		if not x then
			return self[item][1]
		end
		for i = 1,table.count(self[item]) do
			local p,s = path.find(vec2:new(x,y),table.getValue(self[item]),table.getKey(self[item]).map)
			if s then
				p[#p] = nil -- remove current tile
				return p, self[item][1]
			end
		end
	else
		return false
	end
end

function itemManeger:findEmpty(x,y,s)
	local world = self.map
	local f = function(x,y)
		if world[x] and world[x][y] and not world[x][y].item and world[x][y].object.name == "none" then
			return true
		end
		return false
	end
	x,y = path.loop(f,x,y,10,not s)
	
	if self.map then
		return self.map[x][y]
	end
	return x,y
end

function itemManeger:invExist(inv)
	for mat,amu in pairs(inv) do
		if not self[mat] or table.count(self[mat] )== 0 then
			return false
		end
	end
	return true
end