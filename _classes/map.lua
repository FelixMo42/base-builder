map = class:new({
	maxZoom = 200, minZoom = 30,
	width = 100, height = 100,
	x = 0, y = 0, scale = 50,
	jobQueue = {}, players = {},
	speed = 1, rooms = {}
})

function map:load()
	self.jobQueue = {}; self.players = {}
	for x = 0,self.width-1 do
		self[x] = self[x] or {}
		for y = 0,self.height-1 do
			self:setTile(x,y,tiles.grass)
		end
	end
	if self.x == -1 then
		self.x = (self.width-screen.x/self.scale)/2
	end
	if self.y == -1 then
		self.y = (self.height-screen.y/self.scale)/2
	end
end

function map:update(dt)
	dt = dt * self.speed
	for i = 1,#self.players do
		self.players[i]:update(dt)
	end
end

function map:draw()
	--tiles
	local mx,my = math.max(math.floor(self.x),0), math.max(math.floor(self.y),0)
	local mw,mh = screen.x / self.scale + 1, screen.y / self.scale + 1
	for x = mx, math.min(mx+mw,self.width-1) do
		for y = my, math.min(my+mh,self.height-1)  do
			self[x][y]:draw()
		end
	end
	--borders
	love.graphics.setColor(color.black)
	local bx, by = -self.x+math.ceil(self.x),-self.y+math.ceil(self.y)
	for x = -1,screen.x/self.scale+1 do
		for y = -1,screen.y/self.scale+1 do
			love.graphics.rectangle("line",(x+bx)*self.scale,(y+by)*self.scale,self.scale,self.scale)
		end
	end
	--player
	for i =  1,#self.players do
		self.players[i]:draw()
	end
	--debug
	love.graphics.print("speed: "..self.speed,5,5)
end

function map:mousemoved(x,y,dx,dy)
	if love.mouse.isDown(2, 3) then
		self.x = math.min(math.max(self.x - (dx/self.scale),0),self.width-screen.x/self.scale)
		self.y = math.min(math.max(self.y - (dy/self.scale),0),self.height-screen.y/self.scale)
	end
end

function map:mousereleased(x, y, button)
	local m,b = mouse, button
	if not mouse.selected or (self[m.tile.x][m.tile.y].player and m.selected.type == "player") and b == 1 then
		m.selected = self[m.tile.x][m.tile.y].player
	elseif m.selected.type == "player" then
		m.selected:pressed(m.tile.x,m.tile.y,b)
	elseif not m.drag and b == 1 then
		self:tilePressed(m.tile.x,m.tile.y)
	elseif m.tile.drag and b == 1 then
		for x = m.tile.drag.x,m.tile.x,math.sign(m.tile.x-m.tile.drag.x+0.1) do
			for y = m.tile.drag.y,m.tile.y,math.sign(m.tile.y-m.tile.drag.y+0.1) do
				if x == m.tile.drag.x or x == m.tile.x or y == m.tile.drag.y or y == m.tile.y or not m.selected.name:find("wall") then
					self:tilePressed(x,y)
				end
			end
		end
	end
end

function map:wheelmoved(x,y)
	local s = math.min(math.max(self.scale + y, self.minZoom), self.maxZoom)
	self.x = math.min(math.max(self.x + ((screen.x/self.scale)-(screen.x/s))/2,0),self.width-screen.x/self.scale)
	self.y = math.min(math.max(self.y + ((screen.x/self.scale)-(screen.x/s))/2,0),self.height-screen.y/self.scale)
	self.scale = s
	game.mousemoved(mouse.x,mouse.y,0,0)
end

function map:keyreleased(key)
	if key == "space" then
		self.speed = self.speed == 0 and 1 or 0
	end
	if key == "left" then
		self.speed = self.speed - 0.5
	end
	if key == "right" then
		self.speed = self.speed + 0.5
	end
	if key == "s" then
		world:save()
	end
end

function map:setTile(x,y,t)
	self[x][y] = (t):new({
		x = x, y = y,
		map = self,
	})
	if not self[x][y].object or self[x][y].object.name == "none" then
		self[x][y].object = objects.none:new({tile = self[x][y]})
	else
		self[x][y].object.tile = self[x][y]
	end
end

function map:changeTile(x,y,t)
	local j = self[x][y].job
	self[x][y] = self[x][y]:new(t:new())
	self[x][y].job = j
	if self[x][y].object then
		self[x][y].object.tile = self[x][y]
	end
	for job in pairs(self[x][y].job) do
		self[x][y].job[job].tile = self[x][y]
	end
end

function map:tilePressed(x,y)
	if mouse.selected.type == "tile" then
		self[x][y]:changeType(mouse.selected)
	elseif mouse.selected.type == "object" then
		self[x][y]:instalObject(mouse.selected)
	end
end

function map:tileWalkeble(x,y)
	if self[x] and self[x][y] and self[x][y]:walkeble() then
		return true
	end
end

function map:addPlayer(x,y,p)
	if type(x) == "table" then
		self.players[#self.players+1] = x:new({
			map = self, x = x, y = y
		})
	else
		self.players[#self.players+1] = (p or player):new({
			map = self, x = x, y = y
		})
	end
end

function map:save(file)
	local s = "local w = {}\n"
	s = s .. "w = world:new("..fileSystem.saveTable(self)..")\n"
	--save tiles
	for x = 0,self.width-1 do
		for y = 0,self.height-1 do
			s = s .. "w:setTile("..x..","..y..","..self[x][y]:save()..")\n"
		end
	end
	--players
	for i = 1,#self.players do
		s = s.."w:addPlayer()\n"
		s = s.."w.players[#w.players] = w.players[#w.players]:new("
		s = s..self.players[i]:save()..")\n"
	end
	s = s .. "return w"
	fileSystem.saveToFile("map", s)
	return s
end