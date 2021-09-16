require "bootstrap"
print("hello battle&ability system!")
----------------------------------------

local entity=require "battle_entity"
local context=require "battle_context"

local argv={}
local systems={
    "battle_system_property",
    "battle_system_gameplay_battlefield",

    "battle_system_projectile_think",
    "battle_system_projectile_tween",
    
    "battle_system_behaviour",
    "battle_system_action_die",
    "battle_system_action_search",
    "battle_system_action_attack",
    "battle_system_action_idle",
}

local ctx=context.new(argv,systems)

local function new_unit(team_id)
	local unit=entity.new_unit() do
		unit.identity.team_id=team_id
        unit.transform.position={0,0}
	end
	ctx.world:add_entity(unit)
end

new_unit(1)
new_unit(2)

for i=1,10 do
	ctx:update()
end