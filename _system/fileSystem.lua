fileSystem = {}

function fileSystem.saveTable(t,b)
	if b == nil then b = true end
	if b then local s = "{\n" end
	if not b then local s = "\n" end
	for k,v in pairs(t) do
		if type(v) == "string" then
			s = s .. k .. " = '" .. tostring(v) .. "',\n"
		elseif type(v) ~= "table" and type(v) ~= "function" then
			s = s .. k .. " = " .. tostring(v) .. ",\n"
		end
	end
	if b then
		s = s .. "}"
	end
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