local ai=require "ai"

local system={}

local function refresh_state(obj)
    local dynamic=obj.property.dynamic
    local static=obj.property.static
    local state=obj.state
    local ai_state=obj.ai_state
    local target=obj.targets.current

    ai_state.DEAD=dynamic.health<=0
    if ai_state.DEAD then return end

    ai_state.CAN_ATTACK=dynamic.attack_interval<=0
    ai_state.HAS_ATTACK_TARGET=obj.targets.current~=nil
end

local function todo(obj,act)
    if not act then return false end
    if obj[act] then return false end

    local doing=obj.behaviour.name
    if not doing then goto DO_IT end
    if ai:exchange(doing,act) then goto DO_IT end
    goto ENDED

    ::DO_IT:: do
        obj.behaviour.name=act
        return true
    end
    ::ENDED:: do
        return false
    end
end

local function plan(obj)
    local act=ai:plan(obj.ai_state) 
    if todo(obj,act) then
        obj:add_component(act)
    end
end

function system.filter(e)
    return e.behaviour
        and e.state 
        and e.ai_state
        and e.property 
        and e.targets
        and e.transform
        and e.alive_trace_flag
end

function system.update(sys)
    local objs=sys.__entities
    for i=1,#objs do
        local obj=objs[i]
        refresh_state(obj)
        plan(obj)
    end
end

return system