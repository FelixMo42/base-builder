object = class:new({
	width = 1, height = 1,
	type = "object",
	color = color.none,
	moveCost = 0,
	buildTime = 1,
	name = "def",
	required = {},
	tileReq = {t = false},
	inventory = {},
	load = class.tableCopyLoad
})

function object:draw()
	local x = (self.tile.x-self.tile.map.x-self.width+1)*self.tile.map.scale
	local y = (self.tile.y-self.tile.map.y-self.height+1)*self.tile.map.scale
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",x,y,self.tile.map.scale*self.width,self.tile.map.scale*self.height)
end

function object:print()
	local s = ""
	if self.name ~= "none" then
		s = s .. "object: "..self.name
	end
	return s
end

function object:addItem(item)
	if self.inventory[item.name] then
		local i = self.inventory[item.name]
		if i.amu + item.amu >= i.stackSize then
			item.amu = item.amu - (i.stackSize - i.amu)
			i.amu = i.stackSize
		else
			i.amu = i.amu + item.amu
			item.amu = 0
		end
		return true
	end
	return false
end

function object:addInv(inv)
	if not self.inventory[inv.name] then
		self.inventory[inv.name] = inv
	end
end

function object:cheakTile(tile)
	for x = 0,self.width-1 do
		for y = 0, self.height-1 do
			if tile.map[tile.x-x][tile.y-y].object.name ~= "none" then
				return false
			end
		end
	end
	return true
end

function object:destroy(o)
	local t = self.tile
	for inv, amu in pairs(self.required) do
		t:addItem( items[inv]:new({amu = amu, tile = t}) )
		t = self.tile.map.itemManeger:findEmpty(self.tile.x,self.tile.y)
	end
	self.tile.object = o or objects.none:new()
end

objects = {}
objects.none = object:new({
	name = "none", 
	draw = function() end
})
objects.wall = object:new({
	name = "wall",
	color = color.brown,
	moveCost = -1,
	required = {wood = 10}
})
objects.tree = object:new({
	tileReq = {t = true, grass = ""},
	name = "tree",
	required = {wood = 50},
	moveCost = -1,
	color = color.brown,
	draw = function(self)
		local x = (self.tile.x-self.tile.map.x-self.width+1)*self.tile.map.scale+self.tile.map.scale/2
		local y = (self.tile.y-self.tile.map.y-self.height+1)*self.tile.map.scale+self.tile.map.scale/2
		love.graphics.setColor(self.color)
		love.graphics.circle("fill",x,y,self.tile.map.scale*self.width/2,self.tile.map.scale*self.height/2)
	end
})
objects.stockPile = object:new({
	name = "stockPile",
	color = color.transWhite,
	buildTime = 0,
	load = function(self,o)
		self.inventory = {}
		if self.tile then
			self.j = job:new({
				tile = self.tile,
				overlap = true,
				queue = self.tile.map.jobQueue,
			})
			self.j:setReqMat({wood = 50},self)
		end
	end,
	addItem = function(self,item)
		if self.inventory[item.name] then
			local i = self.inventory[item.name]
			if i.amu + item.amu >= i.stackSize then
				item.amu = item.amu - (i.stackSize - i.amu)
				i.amu = i.stackSize
			else
				i.amu = i.amu + item.amu
				item.amu = 0
			end
			self.tile.item = self.inventory[item.name]
			self.inventory[item.name].tile = self.tile
			self.j:cancel()
			self.tile.map.itemManeger:addItem(self.tile)
			if self.tile.item.amu < self.tile.item.stackSize then
				self.j = job:new({
					tile = self.tile,
					overlap = true,
					queue = self.tile.map.jobQueue,
				})
				self.j:setReqMat({wood = 50},self)
			end
			return true
		end
		return false
	end,
	itemTaken = function(self,amu)
		self.j:cancel()
		if self.tile.item then
			self.inventory[self.tile.item.name] = self.tile.item
		else
			self.inventory["wood"] = nil
		end
		if not self.tile.item or self.tile.item.amu < self.tile.item.stackSize then
			self.j = job:new({
				tile = self.tile,
				overlap = true,
				queue = self.tile.map.jobQueue,
				clear = false
			})
			if self.tile.item then
				self.j:setReqMat({wood = self.tile.item.stackSize-self.tile.item.amu},self)
			else
				self.j:setReqMat({wood = 50},self)
			end
		end
	end
})