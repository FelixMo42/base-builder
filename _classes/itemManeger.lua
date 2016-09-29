itemManeger = class:new({map=map})

function itemManeger:addItem(tile)
	if not self[tile.item.name] then
		self[tile.item.name] = {} 
	end
	self[tile.item.name][#self[tile.item.name]+1] = tile
end

function itemManeger:remouveItem(tile)
	table.removeValue(self[tile.item.name],tile)
end

function itemManeger:findItem(item,x,y)
	if self[item] and #self[item] > 0 then
		if not x then
			return self[item][1]
		end
		for i = 1,#self[item] do
			local p,s = path.find(vec2:new(x,y),vec2:new(self[item][i].x,self[item][i].y),self[item][i].map)
			if s then
				p[#p] = nil -- remove current tile
				return p, self[item][1]
			end
		end
	else
		return false
	end
end

function itemManeger:findEmpty(x,y)
	local world = self.map
	local f = function(x,y)
		if world[x] and world[x][y] and not world[x][y].item then
			return true
		end
		return false
	end
	local x,y = path.loop(f,x,y)
	if self.map then
		return self.map[x][y]
	end
	return x,y
end

function itemManeger:invExist(inv)
	for mat,amu in pairs(inv) do
		if not self[mat] or #self[mat] == 0 then
			return false
		end
	end
	return true
end