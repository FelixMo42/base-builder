player = class:new({
	type = "player",
	x = 0, y = 0, tps = 5,
	path = {}, i = 1,
	map = map, name = "bob",
	color = color.blue
})

function player:load()
	if self.map and self.x and self.y then
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
	--get job from nabours
	if not self.job and not self.cheaked then
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
	--loop all jobs
	while not self.job and #self.map.jobQueue >= self.i do
		local j = self.map.jobQueue[self.i]
		local p, s = self:pathfind(vector2:new(self.tile.x,self.tile.y),vector2:new(j.tile.x,j.tile.y),self.map)
		if s then
			self:getJob(j,p)
			self.i = 0
		end
		self.i = self.i + 1
	end
	if self.i - #self.map.jobQueue > 1 then
		self.i = 1
	end
	--calc path
	if #self.path > 0 then
		local p = 1/math.sqrt((self.path[#self.path].x-self.tile.x)^2+(self.path[#self.path].y-self.tile.y)^2)
		local x = (self.path[#self.path].x-self.tile.x) * dt * self.tps * p
		local y = (self.path[#self.path].y-self.tile.y) * dt * self.tps * p
		self.x = self.x + x
		self.y = self.y + y
		x = math.abs(self.x - self.tile.x) >= math.abs(self.path[#self.path].x - self.tile.x)
		y = math.abs(self.y - self.tile.y) >= math.abs(self.path[#self.path].y - self.tile.y)
		if x and y then
			self.x, self.y = self.path[#self.path].x, self.path[#self.path].y
			self:registerTile(self.path[#self.path].x, self.path[#self.path].y)
			self.path[#self.path] = nil
		end
	end
	--work on job
	if self.job and #self.path == 0 then
		if self.job:update(dt) then
			self:jobEnded()
		end
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
end

function player:pathfind(start,target,map,targetOk)
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

function player:save()
	local s = fileSystem.saveTable(self) 
	return s
end

function player:pressed(x,y,b)
	if b == 1 and not mouse.drag and (x ~= self.x or y ~= self.y) and self.map:tileWalkeble(x,y) then
		local p,s = self:pathfind(vector2:new(self.tile.x,self.tile.y),vector2:new(x,y),self.map,false)
		if s then
			if self.job then
				self:returnJob()
			end
			self.job = job:new({jobTime = 0, tile = self.map[x][y], queue = self})
			if #self.path > 0 then
				local n = self.path[#self.path]
				self.path = p
				self.path[#self.path + 1] = n
			else
				self.path = p
				self.path[#self.path] = nil -- remove current tile
			end
			self.job.name = "move"
		end
	elseif b == 2 and self.map[x][y]:hasJob() and not mouse.drag then
		j = self.map[x][y]:getJob()
		local p,s = self:pathfind(vector2:new(self.tile.x,self.tile.y),vector2:new(x,y),self.map)
		if s then
			if self.job then
				self:returnJob()
			end
			self:getJob(j,p)
		end
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

function player:getJob(j,p,keepLast)
	local p = p or self:pathfind(vector2:new(self.tile.x,self.tile.y),vector2:new(j.tile.x,j.tile.y),self.map)
	self.job = j -- get job
	table.removeValue(self.job.queue, j) -- remouve job from queue
	j.queue = self -- add to new queue
	function j:jobCanceled()
		self.queue.path = {self.queue.path[#self.queue.path]}
	end
	if #self.path > 0 then
		local n = self.path[#self.path]
		self.path = p
		self.path[#self.path + 1] = n
	else
		self.path = p
		self.path[#self.path] = nil -- remove current tile
	end
	if not keepLast then
		table.remove(self.path,1) -- remove target tile
	end	
end

function player:jobEnded()
	self.cheaked = false
	self.job = nil
end