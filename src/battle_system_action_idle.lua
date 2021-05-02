local co=coroutine
local system={}

local function idle(obj)

end

function system.filter(e)
	return e.action_idle
		and e.behaviour
		and e.alive_trace_flag
end

function system.join(sys,e)
end

function system.update(sys)
    local objs=sys.__entities
    for i=1,#objs do
    	idle(objs[i])
    end
end

return system