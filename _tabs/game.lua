function game.load()
	--system
		tabs.def = "game"
	--map
		world = map:new()
		world:addPlayer()
		world:addPlayer(1,0)
	--mouse
		mouse.tile = vector2:new(0,0)
		mouse.type = tiles.floor
	--ui
		game.ui = {}
		game.ui[1] = button:new({
			func = function(self) game.tab = self.data end,
			h = 35, text = "build floor", data = "floor",
			x = 0, ry = 0, e = 0, xs = 0,
		})
		game.ui[2] = game.ui[1]:new({
			text = "build objects", data = "objects"
		})
		game.ui[3] = game.ui[1]:new({
			text = "saves", data = "saves"
		})
	--tabs
		game.tabs = {}
		for i = 1,#game.ui do
			game.tabs[game.ui[i].data] = {}
		end
		game.tabs.floor[1] = game.ui[1]:new({
			text = "destroy", data = tiles.grass, ry = 35, ys = 0,
			func = function(self) mouse.type = self.data end, xs = 2,
		})
		local buildList = {"floor"}
		for i = 1, #buildList do
			game.tabs.floor[#game.tabs.floor+1] = game.tabs.floor[1]:new({
				text = "build "..buildList[i], data = tiles[buildList[i]], ry = (#game.tabs.floor + 1) * 35
			})
		end
		game.tabs.objects[1] = game.tabs.floor[1]:new({
			text = "destroy", data = objects.none
		})
		local buildList = {"wall"}
		for i = 1, #buildList do
			game.tabs.objects[#game.tabs.objects+1] = game.tabs.objects[1]:new({
				text = "build "..buildList[i], data = objects[buildList[i]], ry = (#game.tabs.objects + 1) * 35
			})
		end
		game.tabs.saves[1] = game.tabs.floor[1]:new({
			text = "restart", func = function() world = map:new() end
		})
end

function game.update(dt)
	--map
		world:update(dt)
end

function game.draw()
	--map
		world:draw()
	--mouse
		local x,y,w,h = 0,0,world.scale,world.scale
		if mouse.tile.drag then
			local dx = math.sign(mouse.tile.x-mouse.tile.drag.x)
			local dy = math.sign(mouse.tile.y-mouse.tile.drag.y)
			x = (mouse.tile.drag.x - world.x - math.min(dx,0)) * w
			y = (mouse.tile.drag.y - world.y - math.min(dy,0)) * h
			w = w * (mouse.tile.x - mouse.tile.drag.x + 1 + math.sign(dx+0.1) - 1)
			h = h * (mouse.tile.y - mouse.tile.drag.y + 1 + math.sign(dy+0.1) - 1)
		else
			x,y = (mouse.tile.x-world.x)*w, (mouse.tile.y-world.y)*h
		end
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill",x,y,w,h)
	--tab
		if game.tab then
			for i = 1,#game.tabs[game.tab] do
				game.tabs[game.tab][i]:draw()
			end
		end
	--ui
		for i = 1,#game.ui do
			game.ui[i]:draw()
		end
end

function game.mousemoved(x,y,dx,dy)
	--map
		world:mousemoved(x,y,dx,dy)
	--mouse
		mouse.tile.x = math.floor(x/world.scale + world.x)
		mouse.tile.y = math.floor(y/world.scale + world.y)
end

function game.mousepressed(x, y, button, istouch)
	--mouse
		if button == 1 then
			for i = 1,#game.ui do
				if game.ui[i]:onPressed() then
					return true
				end
			end
			if game.tab then
				for i = 1,#game.tabs[game.tab] do
					if game.tabs[game.tab][i]:onPressed() then
						return true
					end
				end
			end
			mouse.tile.drag = {}
			mouse.tile.drag.x = math.floor(x/world.scale + world.x)
			mouse.tile.drag.y = math.floor(y/world.scale + world.y)
		end
end

function game.mousereleased(x, y, button, istouch)
	--ui
		if not mouse.drag then
			for i = 1,#game.ui do
				if game.ui[i]:onPressed() then
					mouse.drag = true
				end
			end
		end
	--tab
		if game.tab and not mouse.drag then
			for i = 1,#game.tabs[game.tab] do
				if game.tabs[game.tab][i]:onPressed() then
					mouse.drag = true
				end
			end
		end
	--map
		world:mousereleased(x, y, button)
	--mouse
		mouse.tile.drag = nil
end

function game.wheelmoved(x,y)
	--map
		world:wheelmoved(x,y)
end

function game.keyreleased(key)
	--tabs
		if key == "escape" then
			game.tab = nil
			return true
		end
	--map
		world:keyreleased(key)
end

function game.resize(w,h)
	--ui
		for i = 1,#game.ui do
			game.ui[i].w = screen.x/#game.ui
			game.ui[i].x = game.ui[i].w*(i-1)
			game.ui[i]:update()
		end
	--tabs
		for k, tab in pairs(game.tabs) do
			for i = 1,#tab do
				tab[i]:update()
			end
		end
end