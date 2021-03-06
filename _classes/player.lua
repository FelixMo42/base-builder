player = class:new({
	type = "player",
	x = 0, y = 0,
	speed = 5,
	path = {},
	i = 1,
	map = map,
	name = "bob",
	color = color.blue
})

function player:load(o)
	if self.map then
		self.map[self.x][self.y].player = self
		self.tile = self.map[self.x][self.y]
	end
end

function player:registerTile(x,y)
	self.tile.player = nil
	self.map[x][y].player = self
	self.tile = self.map[x][y]
end

function player:update(dt)
	if not self.job and #self.path == 0 then
		self:findJob(dt)
	end
	if #self.path > 0 then
		self:move(dt)
	end
	if self.job and #self.path == 0 then
		self:workOnJob(dt)
	end
end

function player:draw()
	local s = self.map.scale
	--draw path if selected
	if mouse.selected == self and #self.path > 0 then
		love.graphics.setColor(color.white)
		for i = 2,#self.path+1 do
			if i == #self.path+1 then
				love.graphics.line((self.x-self.map.x)*s+s/2,(self.y-self.map.y)*s+s/2 ,
				(self.path[i-1].x-self.map.x)*s+s/2,(self.path[i-1].y-self.map.y)*s+s/2)
			else
				love.graphics.line((self.path[i-1].x-self.map.x)*s+s/2,(self.path[i-1].y-self.map.y)*s+s/2 , 
				(self.path[i].x-self.map.x)*s+s/2,(self.path[i].y-self.map.y)*s+s/2)
			end
		end
		love.graphics.circle("fill",(self.path[1].x-self.map.x)*s+s/2,(self.path[1].y-self.map.y)*s+s/2,s/6,s/6)
	end
	--draw self
	love.graphics.setColor(self.color)
	love.graphics.circle("fill",(self.x-self.map.x)*s+s/2,(self.y-self.map.y)*s+s/2,s/2-2,s/2-2)
	love.graphics.setColor(color.black)
	love.graphics.circle("line",(self.x-self.map.x)*s+s/2,(self.y-self.map.y)*s+s/2,s/2-2,s/2-2)
	--item
	if self.item then
		love.graphics.print(self.item.name.." * "..self.item.amu,(self.x-self.map.x)*s,(self.y-self.map.y)*s)
	end
end

function player:save()
	local s = "player:new({"
	s = s..fileSystem.saveTable(self,false)
	return s..")}"
end

function player:pressed(x,y,b)
	if b == 1 and not mouse.drag and (x ~= self.x or y ~= self.y) and self.map:tileWalkeble(x,y) then
		local p,s = path.find(vec2:new(self.tile.x,self.tile.y),vec2:new(x,y),self.map,false)
		if s then
			if #self.path > 0 then
				local n = self.path[#self.path]
				self.path = p
				self.path[#self.path + 1] = n
			else
				self.path = p
				self.path[#self.path] = nil -- remove current tile
			end
		end
	elseif b == 2 and self.map[x][y]:hasJob() and not mouse.drag then
		j = self.map[x][y]:getJob()
		local p,s = path.find(vec2:new(self.tile.x,self.tile.y),vec2:new(x,y),self.map)
		if s then
			if self.job then
				self:returnJob()
			end
			self:getJob(j)
		end
	end
end

function player:findJob()
	if self.i - #self.map.jobQueue > 1 then
		self.i = 1
	end
	if not self.cheaked then
		for k,v in pairs(self.tile:getNeighbours(true,1)) do
			if v:hasJob() then
				if v:walkeble() then
					self:getJob(v:getJob())
					break
				end
			end
		end
		self.cheaked = true
	end
	while self.i <= #self.map.jobQueue do
		local j = self.map.jobQueue[self.i]
		local p, s = path.find(vec2:new(self.tile.x,self.tile.y),vec2:new(j.tile.x,j.tile.y),self.map)
		if s and (not j.reqMat or self.map.itemManeger:invExist(j.reqMat)) then
			self:getJob(j)
			self.i = 1
			break
		end
		self.i = self.i + 1
	end
end

function player:returnJob()
	if not self.job.name or self.job.name ~= "move" then
		self.job.queue = self.map.jobQueue
		self.map.jobQueue[#self.map.jobQueue+1] = self.job
	end
	self.job = nil
	self.path = {self.path[#self.path]}
end

function player:getJob(j)
	self.job = j -- get job
	table.removeValue(self.job.queue, j) -- remouve job from queue
	j.queue = self -- add to new queue
end

function player:jobEnded()
	self.cheaked = false
	self.job = nil
end

function player:workOnJob(dt)
	--make sure we have a job
	if not self.job then
		return false
	end
	--pick up item on work tile
	if self.job.tile.item and self.job.object and self.job.clear then
		if self.item and self.item.amu == self.item.stackSize then
			if self.tile == self.job.tile or self.tile.item or self.tile.object.name ~= "none"  then
				local t = self.map.itemManeger:findEmpty(self.x,self.y)
				self.path = path.find(vec2:new(self.x,self.y),vec2:new(t.x,t.y),self.map,true)
				self.path[#self.path] = nil -- remove current tile
				return true
			else
				self:dropItem()
				return self:workOnJob(dt)
			end
		elseif self.tile == self.job.tile then
			self:pickUpItem(-1)
			return self:workOnJob(dt)
		else
			self.path = path.find(vec2:new(self.x,self.y),vec2:new(self.job.tile.x,self.job.tile.y),self.map,self.map)
			self.path[#self.path] = nil
			return true
		end
	end
	--get mat for job
	if self.job.reqMat and not self.job:hasReqMat() then
		if self.item and self.job.reqMat[self.item.name] then -- do i have object
			if self.item.amu < self.job.reqMat[self.item.name] and self.job.getAll then
				if self.tile.item and self.tile.item.name == self.item.name then
					self:pickUpItem(self.job.reqMat[self.item.name] - self.item.amu)
					return self:workOnJob(dt)
				else
					local p = self.map.itemManeger:findItem(self.item.name,self.x,self.y)
					if p then
						self.path = p
					else
						self:returnJob()
					end
					return true
				end
			elseif self.job:atJob(self.x,self.y,true) then -- am i on tile
				self:useItem()
				return self:workOnJob(dt)
			else
				self.path = path.find(vec2:new(self.x,self.y),vec2:new(self.job.tile.x,self.job.tile.y),self.map,self.job.overlap)
				self.path[#self.path] = nil -- remove current tile
				if not self.job.overlap then table.remove(self.path,1) end -- remove target tile
				return true
			end
		end

		if self.tile.item and self.job.reqMat[self.tile.item.name] and not self.item then
			self:pickUpItem(self.job.reqMat[self.tile.item.name])
			return self:workOnJob(dt)
		elseif not self.item then
			local v,k = table.getValue(self.job.reqMat)
			local p = self.map.itemManeger:findItem(k,self.x,self.y)
			if p then
				self.path = p
			else
				self:returnJob()
			end
			return true
		end

		if self.item and not self.job.reqMat[self.item.name] then
			if not self.tile.item or self.tile.item.name == self.item.name and self.tile.item.amu < self.item.stackSize then
				self:dropItem()
				return self:workOnJob(dt)
			else
				local t = self.map.itemManeger.find.findEmpty(self.x,self.y)
				self.path = path.find(vec2:new(self.x,self.y),vec2:new(t.x,t.y),self.map,true)
				self.path[#self.path] = nil -- remove current tile
				return true
			end
		end
	end
	--work on job
	if not self.job.reqMat or self.job:hasReqMat() then
		if self.job:atJob(self.x,self.y,true) then
			self.job:update(dt)
		else
			self.path = path.find(vec2:new(self.x,self.y),vec2:new(self.job.tile.x,self.job.tile.y),self.map,self.map,self.job.overlap)
			self.path[#self.path] = nil -- remove current tile
			if not self.job.overlap then table.remove(self.path,1) end -- remove target tile
		end
	end
end

function player:move(dt)
	if self.map[self.path[#self.path].x][self.path[#self.path].y]:walkeble() then
		local p = 1/math.sqrt((self.path[#self.path].x-self.tile.x)^2+(self.path[#self.path].y-self.tile.y)^2)
		local x = (self.path[#self.path].x-self.tile.x) * dt * self.speed * p
		local y = (self.path[#self.path].y-self.tile.y) * dt * self.speed * p
		self.x = self.x + x
		self.y = self.y + y
		x = math.abs(self.x - self.tile.x) >= math.abs(self.path[#self.path].x - self.tile.x)
		y = math.abs(self.y - self.tile.y) >= math.abs(self.path[#self.path].y - self.tile.y)
		if x and y then
			self.x, self.y = self.path[#self.path].x, self.path[#self.path].y
			self:registerTile(self.path[#self.path].x, self.path[#self.path].y)
			self.path[#self.path] = nil
		end
	elseif math.floor(self.x) == self.x and math.floor(self.y) == self.y then
		self.path = {}
	else
		self.x = self.tile.x
		self.y = self.tile.y
	end
end

function player:useItem(object)
	object = object or self.job.tile.object
	object:addItem(self.item)
	if self.item.amu == 0 then
		self.item = nil
	end
end

function player:dropItem()
	self.tile:addItem(self.item)
	if self.item.amu == 0 then
		self.item = nil
		return true
	end
	return false
end

function player:pickUpItem(amu)
	local amu = amu or -1
	if amu == -1 then
		amu = self.tile.item.amu
	end
	if self.item then
		amu = math.min(self.item.stackSize-self.item.amu, amu)
	else
		amu = math.min(self.tile.item.amu, amu)
	end

	if not self.tile.item or (self.item and self.tile.item.name ~= self.item.name) then
		return false
	elseif not self.item then
		if self.tile.item.amu <= amu then
			self.item = self.tile.item
			self.map.itemManeger:remouveItem(self.tile)
			self.tile:itemTaken(-1)
		else
			self.item = self.tile.item:new({amu = amu})
			self.tile:itemTaken(amu)
		end
	else
		if self.tile.item.amu <= amu then
			self.item.amu = self.item.amu + self.tile.item.amu
			self.map.itemManeger:remouveItem(self.tile)
			self.tile:itemTaken(-1)
		else
			self.item.amu = self.item.amu + amu
			self.tile:itemTaken(amu)
		end
	end
	return true
end