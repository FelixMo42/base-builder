object = class:new({
	width = 1, height = 1,
	type = "object",
	color = color.none,
	moveCost = 0,
	buildTime = 1,
	name = "def",
	required = {},
	iventory = {},
	load = class.tableCopyLoad
})

function object:draw()
	local x = (self.tile.x-self.tile.map.x)*self.tile.map.scale
	local y = (self.tile.y-self.tile.map.y)*self.tile.map.scale
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",x,y,self.tile.map.scale,self.tile.map.scale)
end

function object:print()
	local s = ""
	if self.name ~= "none" then
		s = s .. "object: "..self.name.."\n"
	end
	return s
end

function object:addItem(item)
	if self.iventory[item.name] then
		local i = self.iventory[item.name]
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
	if not self.iventory[inv.name] then
		self.iventory[inv.name] = inv
	end
end

objects = {}
objects.none = object:new({name = "none",draw = function() end})
objects.wall = object:new({name = "wall", color = color.brown, moveCost = -1, required = {wood = 10}})