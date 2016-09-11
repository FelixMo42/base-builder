job = class:new({
	tile = tile,
	jobTime = 1
})

function job:load()
	if self.queue then
		self.queue[#self.queue+1] = self
	end
end

function job:update(dt)
	self.jobTime = self.jobTime - dt
	if self.jobTime <= 0 then
		table.removeValue(self.queue,self)
		if self.jobComplet then
			self:jobComplet()
		end
		return true
	end
	return false
end

function job:cancel()
	if self.jobCanceled then
		self:jobCanceled()
	end
	table.removeValue(self.queue,self)
end

function job:setReqMat(mat,object)
	if table.count(mat) > 0 then
		self.reqMat = mat
		for mat, amu in pairs(mat) do
			object:addInv(items[mat]:new({stackSize = amu, amu = 0}))
		end
	end
end

function job:hasReqMat(object)
	local object = object or self.tile.object
	for mat, amu in pairs(self.reqMat) do
		if object.iventory[mat].amu < amu then
			return false
		end
	end
	return true
end

function job:atJob(x,y,adj)
	if x == self.tile.x and y == self.tile.y then
		return true
	elseif adj and math.abs(self.tile.x-x) <= 1 and math.abs(self.tile.y-y) <= 1 then
		return true
	end
	return false
end