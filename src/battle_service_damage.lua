local meta=require "battle_meta"
local DAMAGE_TYPE=meta.DAMAGE_TYPE

local damage={}

function damage.new(
    source, --who deal the damage
    target, --who take the damage
    value, --base value
    types, --damage type
    flags, --damage flags
    ability --cause 
) return {
        source=source,
        target=target,
        value=value,
        types=types,
        flags=flags,
        ability=ability,

        _free=false,
    }
end

function damage.outgoing(dmg)
    --switch damage_type to change the value
    local effect=dmg.source.property.static.outgoing_damage_effect
    dmg.value=dmg.value*(1+effect)
    dmg._free=true
    return dmg
end

function damage.incoming(dmg)
    --check hit? return false,nil
    local final={
        base=dmg,
        source=dmg.source,
        target=dmg.target,
        total=0,
        overflow=0,
    }
    local effect=dmg.target.property.static.incoming_damage_effect
    final.total=dmg.value*(1+effect)
    --check crit?
    return true,final
end

function damage.min_health(final)
    local static=final.target.property.static
    local dynamic=final.target.property.dynamic

    local hp=dynamic.health
    local min_hp=static.min_health
    local fix=final.total+min_health-hp

    if fix<=0 then return false end

    dynamic.health=hp+fix
    final.overflow=min_hp<=0 and fix or 0
    return true
end

function damage.apply(dmg)
    dmg=dmg._free and dmg or damage.outgoing(dmg)
    local ok,final=damage.incoming(dmg)
    if not ok then return end
    
    local exe=function()
        damage.min_health(final)
        local dynamic=final.taret.property.dynamic
        final.hp_before=dynamic.health
        dynamic.health=dynamic.health-final.total
        final.hp_after=dynamic.health
    end

    ctx().todolist:lpush(exe)
end

return damage
