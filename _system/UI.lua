button = {
	x = 10,y = 10,
	h = 20,w = 100,
	e = 10, s = 2,
	color = {255,255,255},
	textColor = {000,000,000},
	lineColor = {000,000,000},
	text = "PLAY"
}

function button:new(this)
	local this = this or {}
	for k in pairs(self) do
		if not this[k] then
			this[k] = self[k]
		end
	end
	this:update()
	return this
end

function button:update()
	if self.rw then
		self.w = love.graphics.getWidth() - self.rw - self.x
	end
	if self.rh then
		self.h = love.graphics.getHeight() - self.rh - self.y
	end 
	if self.rx then
		self.x = love.graphics.getWidth()- self.rx - self.w
	end
	if self.ry then
		self.y = love.graphics.getHeight() - self.ry - self.h
	end 
end

function button:onPressed()
	if self.x+self.w >= love.mouse.getX() and love.mouse.getX() >= self.x and self.y+self.h >= love.mouse.getY() and love.mouse.getY() >= self.y then
		if self.func then
			return self:func(self) or true
		else
			return true
		end
	end
	return false
end

function button:draw()
	if self.x+self.w >= mouse.x and mouse.x >= self.x and self.y+self.h >= mouse.y and mouse.y >= self.y then
		love.graphics.setColor(self.color)
		local xs,ys = (self.xs or self.s),(self.ys or self.s)
		love.graphics.rectangle("fill",self.x-xs,self.y-ys,self.w+xs*2,self.h+ys*2,self.e)
		love.graphics.setColor(self.lineColor)
		love.graphics.rectangle("line",self.x-xs,self.y-ys,self.w+xs*2,self.h+ys*2,self.e)
	else
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill",self.x,self.y,self.w,self.h,self.e)
		love.graphics.setColor(self.lineColor)
		love.graphics.rectangle("line",self.x,self.y,self.w,self.h,self.e)
	end
	love.graphics.setColor(self.textColor)
	love.graphics.printf(self.text, self.x, self.y+self.h/2-love.graphics.getFont():getHeight()/2, self.w, "center")
end