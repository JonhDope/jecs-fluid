local jecs = require(script.Parent.Parent.jecs)
local fluid = require(script.Parent.Parent.fluid)

local source = fluid.source
local effect = fluid.effect
local read = fluid.read
local cleanup = fluid.cleanup

local exports = {
	world = (nil :: any) :: jecs.World,
}

function get_component<T>(entity: fluid.UsedAs<jecs.Entity?>, id: jecs.Entity<T>): T?
	return if read(entity) then exports.world:get(read(entity), id) else nil
end

function use_entity_get<T>(entity: fluid.UsedAs<jecs.Entity?>, id: jecs.Entity<T>): () -> T?
    local output = source() :: fluid.Source<T?>

	effect(function()
		local entity = read(entity)
		output(get_component(entity, id))
		local component = jecs.IS_PAIR(id) and jecs.pair_first(exports.world, id) or id
		local second = jecs.IS

		cleanup(exports.world:added(component, function(e, _, value)
			if e == entity then
				output(get_component(entity, id))
			end
		end))
		cleanup(exports.world:changed(component, function(e, _, value)
			if e == entity then
				output(get_component(entity, id))
			end
		end))
		cleanup(exports.world:removed(component, function(e, removed)
			if e ~= entity then
				return
			end
			if second == jecs.Wildcard and jecs.IS_PAIR(removed) then
				local value = nil
				local index = 0

				while true do
					local target = exports.world:target(e, component, index)
					if not target then
						break
					end
					index += 1

					if target == jecs.pair_second(exports.world, removed) then
						continue
					end
					value = exports.world:get(e, jecs.pair(component, target))
					break
				end
				output(value)
			else
				if removed == id then
					output(nil)
				end
			end
		end))
	end)

	return output
end

exports.use_entity_get = use_entity_get

return exports