local co=coroutine
local system={}

local __foreswing=2
local __backswing=2

local function attack(obj)
    local act=obj.action_attack
    ::BEGIN::
        act.foreswing=0
        act.backswing=0
    ::FORESWING::
        while act.forsewing<__foreswing do
            act.foreswing=act.foreswing+1
            co.yield()
        end
    ::ATTACK::
        print("attack target")
        obj.property.dynamic.attack_interval=5
    ::BACKSWING::
        while act.backswing<__backswing do
            act.backswing=act.backswing+1
            co.yield()
        end
    ::ENDED::
        obj:rm_component"action_attack"
        obj.behaviour.name=nil
end

function system.filter(e)
    return e.action_attack
        and e.behaviour
        and e.targets
        and e.alive_trace_flag
end

function system.join(sys,e)
    e.action_attack.handle=co.create(attack)
end

function system.update(sys,e)
    local objs=sys.__entities
    for i=1,#objs do
        local obj=objs[i]
        local ok,msg=co.resume(obj.action_attack.handle,obj)
        if not ok then error(msg) end
    end
end

return system
