function love.openTab(t,i)
	--tabs
		if tab and _G[tab].exit then
			_G[tab].exit()
		end
		tab = t
		if _G[tab].open then
			_G[tab].open(i)
		end
		if _G[tab].resize then
			_G[tab].resize(width,height)
		end
end

function love.load()
	--system
		for i,file in pairs(love.filesystem.getDirectoryItems("_system")) do
			if file:find(".lua") then
				require("_system/"..file:gsub(".lua",""))
			end
		end
		for i = 5,150 do
			_G["f"..i] = love.graphics.newFont(i)
		end
		screen = vector2:new(love.graphics.getDimensions())
		love.math.setRandomSeed(os.time())
	--mouse
		mouse = vector2:new(love.mouse.getPosition())
		mouse.drag = false
	--classes
		for i,file in pairs(love.filesystem.getDirectoryItems("_classes")) do
			if file:find(".lua") then
				require("_classes/"..file:gsub(".lua",""))
			end
		end
	--tabs
		tabs = {}
		for i,file in pairs(love.filesystem.getDirectoryItems("_tabs")) do
			if file:find(".lua") then
				file = file:gsub(".lua","")
				_G[file] = {}
				require("_tabs/"..file)
				tabs[#tabs+1] = file
				if _G[file].load then
					_G[file].load()
				end
			end
		end
		love.openTab(tabs.def or tabs[1])
	--saves
		filename = "data.txt"
		if not love.filesystem.isFile(filename) then
			love.filesystem.newFile(filename)
			love.filesystem.write(filename,"")
		end
		loadstring(love.filesystem.read(filename))()
end

function love.update(dt)
	--tabs
		if _G[tab].update then
			_G[tab].update(dt)
		end
end

function love.draw()
	--tabs
		if _G[tab].draw then
			_G[tab].draw()
		end
end

function love.mousemoved(x,y,dx,dy)
	--mouse
		mouse.x = x
		mouse.y = y
		if mouse.dragStart then
			mouse.drag = true
		end
	--tabs
		if _G[tab].mousemoved then
			_G[tab].mousemoved(x,y,dx,dy)
		end
end

function love.mousepressed(x, y, button, istouch)
	--mouse
		mouse.drag = false
		mouse.dragStart = {x = x, y = y}
	--tabs
		if _G[tab].mousepressed then
			_G[tab].mousepressed(x, y, button, istouch)
		end
end

function love.mousereleased(x, y, button, istouch)
	--tabs
		if _G[tab].mousereleased then
			_G[tab].mousereleased(x, y, button, istouch)
		end
	--mouse
		mouse.drag = false
		mouse.dragStart = nil
end

function love.wheelmoved(x,y)
	--tabs
		if _G[tab].wheelmoved then
			_G[tab].wheelmoved(x,y)
		end
end

function love.keypressed(key)
	--tabs
		if _G[tab].keypressed then
			_G[tab].keypressed(key)
		end
end

function love.keyreleased(key)
	--tabs
		if _G[tab].keyreleased then
			_G[tab].keyreleased(key)
		end
end

function love.resize(w,h)
	--system
		screen.x = w
		screen.y = h
	--tabs
		if _G[tab].resize then
			_G[tab].resize(w, h)
		end
end

function love.quit()
	--tabs
		data = ""
		for i = 1,#tabs do
		 	if _G[tab].quit then
				_G[tab].quit(x, y, button, istouch)
			end
		end
	--saves
		love.filesystem.write("data.txt",data)
end