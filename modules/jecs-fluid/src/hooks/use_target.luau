local fluid = require(script.Parent.Parent.fluid)
local jecs = require(script.Parent.Parent.jecs)

local source = fluid.source
local read = fluid.read
local cleanup = fluid.cleanup
local effect = fluid.effect

local exports = {
	world = (nil :: any) :: jecs.World,
}

function get_target(entity: fluid.UsedAs<jecs.Entity?>, relation: jecs.Id<any>): jecs.Entity?
	return read(entity) and exports.world:target(read(entity), relation) or nil
end

function use_target<T>(entity: fluid.UsedAs<jecs.Entity?>, relation: jecs.Id<T>)
	local target = source(get_target(entity, relation))

	effect(function()
		target(get_target(entity, relation))
		if not read(entity) then
			return
		end

		cleanup(exports.world:added(relation, function(added)
			if added == entity then
				target(get_target(entity, relation))
			end
		end))
		cleanup(exports.world:removed(relation, function(removed)
			if removed == entity then
				task.defer(function()
					target(get_target(entity, relation))
				end)
			end
		end))
	end)

	return target
end

exports.use_target = use_target

return exports