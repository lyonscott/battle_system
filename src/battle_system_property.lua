local meta=require "battle_meta"
local pairs=pairs

local system={}

local function init_template_property(e)
    local temp=e.property.template
    temp.health=500
    temp.mana=100
    temp.attack_damage=50
    temp.armor=2
    temp.attack_interval=60
end
local function init_static_property(e)
    local temp=e.property.template
    local static=e.property.static
    for k,v in pairs(meta.property_t) do
        static[k]=temp[k]
    end
end
local function init_dynamic_property(e)
    local static=e.property.static
    local dynamic=e.property.dynamic
    for k,v in pairs(meta.dynamic_property_t) do
        dynamic[k]=static[k]
    end
end
local function refresh_dynamic_property(e)
    local interval=e.property.dynamic.attack_interval
    interval=interval-1
    e.property.dynamic.attack_interval=interval
end

function system.filter(e)
    return e.property 
        and e.state
        and e.identity
end

function system.join(sys,e)
    init_template_property(e)
    init_static_property(e)
    init_dynamic_property(e)
end

function system.update(sys)
    local objs=sys.__entities
    for i=1,#objs do
        refresh_dynamic_property(objs[i])
    end
end

return system