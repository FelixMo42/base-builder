object = class:new({
	width = 1, height = 1,
	type = "object",
	color = color.none,
	moveCost = 0,
	buildTime = 1,
	name = "def"
})

function object:draw()
	local x = (self.tile.x-self.tile.map.x)*self.tile.map.scale
	local y = (self.tile.y-self.tile.map.y)*self.tile.map.scale
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",x,y,self.tile.map.scale,self.tile.map.scale)
end

objects = {}
objects.none = object:new({name = "none",draw = function() end})
objects.wall = object:new({name = "wall",color = color.brown,moveCost = -1})