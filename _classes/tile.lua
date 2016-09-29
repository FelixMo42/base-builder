tile = class:new({
	type = "tile",
	color = color.none,
	buildTime = 1,
	name = "def",
	job = {},
	load = class.tableCopyLoad
})

function tile:draw()
	local x,y = (self.x-self.map.x)*self.map.scale, (self.y-self.map.y)*self.map.scale
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",x,y,self.map.scale,self.map.scale)
	if self.object and self.object.name ~= "none" and self.object.tile == self then
		self.object:draw()
	end
	if table.count(self.job) > 0 then
		love.graphics.setColor(100,100,100,100)
		love.graphics.rectangle("fill",x,y,self.map.scale,self.map.scale)
		love.graphics.setColor(color.black)
		love.graphics.print(math.floor(table.getValue(self.job).jobTime*10)/10,x+2,y+2)
	end
	if self.item and self.item.amu > 0 then
		love.graphics.setColor(color.black)
		self.item:draw()
	end
end

function tile:addItem(item)
	if not self.item then
		self.item = item
		item.tile = self
		self.map.itemManeger:addItem(self)
	elseif item.name ~= self.item.name then
		return false
	elseif self.item.amu + item.amu > self.item.stackSize then
		item.amu = item.amu - (item.stackSize - self.item.amu)
		self.item.amu = item.stackSize
	else
		self.item.amu = self.item.amu + item.amu
		item.amu = 0
	end
	return true
end

function tile:itemTaken(amu)
	if amu == -1 or amu >= self.item.amu then
		self.item = nil
	else
		self.item.amu = self.item.amu - amu
	end
	if self.object and self.object.itemTaken then
		self.object:itemTaken(amu)
	end
end

function tile:instalObject(obj)
	local j = self.job.object
	local shouldBuild = obj.name ~= self.object.name and not j -- should I build
	if j and obj.name == "none" then -- stop object build job
		j:cancel()
		self.job.object = nil
	elseif shouldBuild and obj:cheakTile(self) then -- build object
		if obj.buildTime >= 0 then
			self.job.object = job:new({
				tile = self, object = obj, queue = self.map.jobQueue, jobTime = obj.buildTime,
				jobComplet = function(self)
					for x = 0, self.object.width-1 do
						for y = 0, self.object.height-1 do
							local t = self.tile.map[self.tile.x-x][self.tile.y-y]
							t.job.object = nil
							t.object = self.object:new({tile = self.tile})
						end
					end
				end
			})
			self.job.object:setReqMat(obj.required,self.object)
		else
			self.object = obj:new({tile = self})
		end
	elseif shouldBuild then -- replace object
		if self.object.name ~= "none" then
			self.object.tile.job.object = job:new({
				tile = self.object.tile, object = obj, queue = self.map.jobQueue,
				jobTime = self.object.tile.object.buildTime/2, o = self,
				jobComplet = function(self)
					local o = self.tile.object
					for x = 1, o.width do
						for y = 1, o.height do
							if o.name ~= "none" then
								if self.tile.map[o.tile.x-x+1][o.tile.y-y+1] == o.tile then
									self.tile.map[o.tile.x-x+1][o.tile.y-y+1].object:destroy()
								else
									self.tile.map[o.tile.x-x+1][o.tile.y-y+1].object = objects.none:new()
								end
							end
						end
					end
					o.tile.job.object = nil
					if self.object:cheakTile(self.tile) then
						self.o:instalObject(self.object)
					end
				end
			})
		end
	end
end

function tile:changeType(t)
	local j = self.job.type
	if j and t.name == "grass" then -- stop tile build job
		j:cancel()
		self.job.type = nil
	elseif t.name ~= self.name and not j then -- change tile type
		self.job.type = job:new({tile = self,type = t,queue = self.map.jobQueue, jobTime = t.buildTime})
		function self.job.type:jobComplet()
			self.tile.job.type = nil
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

function tile:getNeighbours(getSelf, dist)
	local n = {}
	for x = -(dist or 1), dist or 1 do
		for y = -(dist or 1), dist or 1 do
			if not (math.abs(x) + math.abs(y) == 0 and getSelf) then
				if self.map[self.x+x] and self.map[self.x+x][self.y+y] then
					n[#n+1] = self.map[self.x+x][self.y+y]
				end
			end
		end
	end
	return n
end

function tile:hasJob(t)
	if t then
		return self.job[t] ~= nil
	else
		return table.count(self.job) > 0
	end
end

function tile:getJob(t)
	if t then
		return self.job[t]
	else
		for k in pairs(self.job) do
			return self.job[k]
		end
	end
end

function tile:save()
	local s = "tiles."..self.name..":new({"
	s = s.."x = "..self.x..", y = "..self.y..",map = w"
	if self.object.name ~= "none" then
		s = s..",object = objects."..self.object.name..":new()"
	end
	s = s.."})"
	return s
end

function tile:print()
	local s = "tile type: "..self.name
	if self.object and self.object.name ~= "none" then
		s = s .. "\n"..self.object:print()
	end
	if self.item then
		s = s .. "\nitem: "..self.item.name.." * "..self.item.amu
	end
 	return s
end

tiles = {}
tiles.grass = tile:new({name = "grass", color = color.green})
tiles.floor = tile:new({name = "floor", color = color.gray})