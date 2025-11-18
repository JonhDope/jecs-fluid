local jecs = require(script.jecs)
local jecs_utils = require(script.jecs_utils)

local hooks = script.hooks
local use_entity_get = require(hooks.use_entity_get)
local use_entity_has = require(hooks.use_entity_has)
local use_query_first = require(hooks.use_query_first)
local use_query = require(hooks.use_query)
local use_target = require(hooks.use_target)

local jecs_fluid = {
	useEntityGet = use_entity_get.use_entity_get,
	useEntityHas = use_entity_has.use_entity_has,
	useQueryFirst = use_query_first.use_query_first,
	useQuery = use_query.use_query,
	useTarget = use_target.use_target,

	use_entity_get = use_entity_get.use_entity_get,
	use_entity_has = use_entity_has.use_entity_has,
	use_query_first = use_query_first.use_query_first,
	use_query = use_query.use_query,
	use_target = use_target.use_target,

	__world = nil :: jecs.World?,
}

function jecs_fluid.world(world: jecs.World)
	if jecs_utils.__world ~= world then
		jecs_utils.world(world)
	end

	use_entity_get.world = world
	use_entity_has.world = world
	use_query_first.world = world
	use_query.world = world
	use_target.world = world
end

return jecs_fluid