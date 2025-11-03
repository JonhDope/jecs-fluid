local fluid = require(script.Parent.Parent.fluid)
local jecs = require(script.Parent.Parent.jecs)

local source = fluid.source
local read = fluid.read
local cleanup = fluid.cleanup
local effect = fluid.effect

local exports = {
	world = (nil :: any) :: jecs.World,
}

function get_tag(entity: fluid.UsedAs<jecs.Entity?>, tag: jecs.Entity)
	return if read(entity) then exports.world:has(read(entity), tag) else false
end

function use_entity_has(entity: fluid.UsedAs<jecs.Entity?>, tag: jecs.Entity)
	local is_tagged = source(get_tag(entity, tag))

	effect(function()
		is_tagged(get_tag(entity, tag))
		cleanup(exports.world:added(tag, function(added)
			if added == read(entity) then
				is_tagged(get_tag(entity, tag))
			end
		end))
		cleanup(exports.world:removed(tag, function(removed)
			if removed == read(entity) then
				task.defer(function()
					is_tagged(get_tag(entity, tag))
				end)
			end
		end))
	end)

	return is_tagged
end

exports.use_entity_has = use_entity_has

return exports