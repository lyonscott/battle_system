local co=coroutine
local system={}

local _duration=5

local function die(obj)
	obj.identity.locked=true
	local act=obj.action_die
	::BEGIN:: do
		act.duration=0
		obj:rm_component"alive_trace_flag"
		obj:add_component"dead_trace_flag"
	end
	::DIE::
		while act.duration<_duration do
			act.duration=act.duration+1
			co.yield()
		end
	::ENDED::
		obj:rm_component"action_die"
end

function system.filter(e)
	return e.action_die
		and e.behaviour
		and e.identity
end

function system.join(sys,e)
    e.action_die.handle=co.create(action_die)
end

function system.update(sys)
    local objs=sys.__entities
    for i=1,#objs do
        local obj=objs[i]
        local ok,msg=co.resume(obj.action_die.handle,obj)
        if not ok then error(msg) end
    end
end

return system