local ctx=require "battle_context"
local system={}

function system.filter(e)
    return e.alive_trace_flag
        and e.identity
end

function system.join(sys,e)
    ctx().alive_units=sys.__entities
end
function system.exit(sys,e)
    ctx().alive_units=sys.__entities
end

return system