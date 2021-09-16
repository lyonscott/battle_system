local damage=require "battle_service_damage"
local projectile=require "battle_service_projectile"
local meta=require "battle_meta"
local co=coroutine
local system={}

local __foreswing=2
local __backswing=2

local function apply_damage(attack)
    damage.apply(attack.damage)
end
local function melee_attack(attack) apply_damage(attack) end
local function range_attack(attack)
    damage.apply(attack.damage)
    projectile.tracking{
        owner=attack.source,
        origin=attack.source,
        target=attack.target,
        speed=100,
        damage=attack.damage,
        on_hit=apply_damage,
        ability=attack, 
    } 
end

local function action_attack(obj)
    local attack=obj.action_attack
    ::BEGIN::
        local target=obj.targets.current
        attack.source=obj
        attack.target=target
        attack.foreswing=0
        attack.backswing=0
        attack.damage=damage.outgoing{
            source=obj,
            target=target,
            value=obj.property.static.attack_damage,
            types=meta.DAMAGE_TYPE.PHYSICAL,
            ability=attack,
        }
    ::FORESWING::
        while attack.foreswing<__foreswing do
            attack.foreswing=attack.foreswing+1
            co.yield()
        end
    ::ATTACK::
        print("attack target")
        range_attack(attack)
        obj.property.dynamic.attack_interval=5
    ::BACKSWING::
        while attack.backswing<__backswing do
            attack.backswing=attack.backswing+1
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
        and e.property
        and e.alive_trace_flag
end

function system.join(sys,e)
    e.action_attack.handle=co.create(action_attack)
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
