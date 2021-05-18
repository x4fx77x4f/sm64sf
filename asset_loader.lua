local Asset = {}
Asset.__index = Asset
Asset.__metatable = "Asset"
function Asset.new(path, type, ...)
	local self = setmetatable({}, Asset)
	self.name = path
	self.path = path
	if not type then
		local ext = string.getExtensionFromFilename(path)
		if ext == 'png' or ext == 'jpg' then
			type = 'material.createFromImage'
		end
	end
	assert(type, "could not figure out type for asset")
	self.type = type
	self.args = {...}
	return self
end
function Asset.newGlobal(name, path, type, ...)
	local asset = Asset.new(path, type, ...)
	asset.name = name
	_G[name] = asset
	return asset
end
function Asset:load()
	if self.type == 'material.createFromImage' then
		self.loaded = material.createFromImage('../data/sf_filedata/', self.path, self.args[1] or '')
	else
		errorf("unknown type %q for asset %s", self.type, self.name)
	end
end
function Asset:unload()
	if not self.loaded then
		return
	end
	self.loaded:destroy()
	self.loaded = nil
end
function Asset:redeem()
	if self.loaded then
		return self.loaded
	end
	printf("WARNING: redeemed asset without loading it first (%s)", self.name)
	self:load()
	return self.loaded
end

Asset.newGlobal('texture_transition_star_half', 'textures/segment2/segment2.0F458.ia8.png')
