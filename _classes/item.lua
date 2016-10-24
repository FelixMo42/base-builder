item = class:new({
	type = "item",
	name = "wood",
	stackSize = 50,
	amu = 1
})

function item:draw()
	if self.tile and self.amu > 0 then
		local s, w, h = self.tile.map.scale, 5,3
		local x, y = (self.tile.x-self.tile.map.x)*s,(self.tile.y-self.tile.map.y)*s
		love.graphics.setColor(color.gray)
		love.graphics.rectangle("fill",x+s/2-s/w/2,y+s/2-s/h/2,s/w,s/h)
		love.graphics.setColor(color.black)
		love.graphics.rectangle("line",x+s/2-s/w/2,y+s/2-s/h/2,s/w,s/h)
		if self.stackSize > 1 then
			love.graphics.printf(self.amu,x+3,y+s-15,s-6,"right")
		end
	end
end

function item:save()
	local s = "items."..self.name..":new({"
	s = s.."stackSize = "..self.stackSize
	s = s..",amu = "..self.amu
	s = s..",tile = w["..self.tile.x.."]["..self.tile.y.."]"
	return s.."})"
end

items = {}
items.wood = item:new({name = "wood", stackSize = 50})