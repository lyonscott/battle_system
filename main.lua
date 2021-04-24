require "bootstrap"
print("hello battle&ability system!")
----------------------------------------

local entity=require "battle_entity"
local context=require "battle_context"

local argv={}
local systems={
    "battle_system_property",
    "battle_system_gameplay_battlefield"
}

local ctx=context.new(argv,systems)
local unit=entity.new_unit()
ctx.world:add_entity(unit)

ctx:update()