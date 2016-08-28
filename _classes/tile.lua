tile = class:new({
	type = "tile",
	color = color.none,
	buildTime = 1,
	name = "def",
})

function tile:draw()
	local x,y = (self.x-self.map.x)*self.map.scale, (self.y-self.map.y)*self.map.scale
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",x,y,self.map.scale,self.map.scale)
	if self.object then
		self.object:draw()
	end
	if self.j then
		love.graphics.setColor(100,100,100,100)
		love.graphics.rectangle("fill",x,y,self.map.scale,self.map.scale)
	end
end

function tile:instalObject(obj)
	local shouldBuild = obj.name ~= self.object.name and not self.j -- should I build
	if self.j and self.j.object and obj.name == "none" then -- stop object build job
		self.j:cancel()
		self.j = nil
	elseif shouldBuild and self.object.name == "none" then -- build object
		self.j = job:new({tile = self, object = obj, queue = self.map.jobQueue, jobTime = obj.buildTime})
		function self.j:jobComplet()
			self.tile.j = nil
			self.tile.object = self.object:new({tile = self.tile})
		end
	elseif shouldBuild then -- replace object
		self.j = job:new({tile = self,object = obj,queue = self.map.jobQueue, jobTime = self.object.buildTime/2})
		function self.j:jobComplet()
			self.tile.j = nil
			self.tile.object = objects.none:new()
			self.tile:instalObject(self.object)
		end
	end
end

function tile:changeType(t)
	if self.j and self.j.type and t.name == "grass" then --  stop tile build job
		self.j:cancel()
		self.j = nil
		return
	elseif t.name ~= self.name and not self.j then -- change tile type
		self.j = job:new({tile = self,type = t,queue = self.map.jobQueue, jobTime = t.buildTime})
		function self.j:jobComplet()
			self.tile.j = nil
			self.tile.map:changeTile(self.tile.x,self.tile.y,self.type)
		end
	end
end

function tile:walkeble()
	if self.moveCost == -1 or self.object.moveCost == -1 then
		return false
	end
	return true
end

tiles = {}
tiles.grass = tile:new({name = "grass", color = color.green})
tiles.floor = tile:new({name = "floor", color = color.gray})