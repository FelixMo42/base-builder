fileSystem = {}

function fileSystem.saveTable(t)
	local s = "{\n"
	for k,v in pairs(t) do
		if type(v) ~= "table" and type(v) ~= "function" then
			s = s .. k .. " = " .. tostring(v) .. ",\n"
		end
	end
	s = s .. "}"
	return s
end

function fileSystem.saveToFile(filename, file)
	filename = filename..".txt"
	if not love.filesystem.isFile(filename) then
		love.filesystem.newFile(filename)
	end
	love.filesystem.write(filename, file)
end

function fileSystem.loadFile(filename)
	filename = filename..".txt"
	if not love.filesystem.isFile(filename) then
		love.filesystem.newFile(filename)
		love.filesystem.write(filename,"")
	end
	return loadstring(love.filesystem.read(filename))()
end