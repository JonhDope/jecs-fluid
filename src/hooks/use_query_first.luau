local fluid = require(script.Parent.Parent.fluid)
local jecs = require(script.Parent.Parent.jecs)
local jecs_utils = require(script.Parent.Parent.jecs_utils)

local query_first = jecs_utils.query_first

local source = fluid.source
local read = fluid.read
local cleanup = fluid.cleanup
local effect = fluid.effect

local exports = {
	world = (nil :: any) :: jecs.World,
}

function use_query_first<T...>(query: fluid.UsedAs<jecs.Query<T...>?>, predicator: ((entity: jecs.Entity, T...) -> boolean)?)
	local current = source(nil :: jecs.Entity?)

	effect(function()
		local queryobj = read(query) :: jecs.Query<...any>
		if not queryobj then
			current(nil)
			return
		end
		local monitor = jecs_utils.monitor(queryobj)

		monitor.added(function(e)
			current(query_first(read(query), predicator :: any))
		end)
		monitor.removed(function()
			task.defer(function()
				current(query_first(read(query), predicator :: any))
			end)
		end)
		current(query_first(queryobj, predicator :: any))
		cleanup(monitor.disconnect)
	end)

	return current
end

exports.use_query_first = use_query_first

return exports