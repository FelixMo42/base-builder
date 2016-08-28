job = class:new({
	tile = tile,
	jobTime = 1,
})

function job:load()
	if self.queue then
		self.queue[#self.queue+1] = self
	end
end

function job:update(dt)
	self.jobTime = self.jobTime - dt
	if self.jobTime <= 0 then
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