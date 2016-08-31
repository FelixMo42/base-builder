class = {}

function class:new(this)
	local this = this or {}
	for k in pairs(self) do
		if not this[k] then
			this[k] = self[k]
		end
	end
	if this.load then
		this:load(self)
	end
	return this
end

vector2 = {}

function vector2:new(x,y)
	local this = {x = x, y = y}
	for k in pairs(self) do
		this[k] = self[k]
	end
	if this.load then
		this:load()
	end
	return this
end

function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function table.removeValue(t,v)
	for k in pairs(t) do
		if t[k] == v then
			if type(k) == "number" then
				table.remove(t,k)
			else
				t[k] = nil
			end
		end 
	end
end

function table.count(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end