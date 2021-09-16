local ctx=require "battle_context"

local system={}

local function search(obj)
    local alive_units=ctx().alive_units
    local enemy={}
    for i=1,#alive_units do
    	local target=alive_units[i]
    	local id=target.identity.team_id
    	
    	if obj.identity.team_id~=id then
    		obj.targets.current=target
    		obj:rm_component "action_search"
    		obj.behaviour.name=nil
    		return
    	end
    end
end

function system.filter(e)
    return e.action_search
        and e.behaviour
        and e.targets
        and e.identity
end

function system.update(sys)
    local objs=sys.__entities
    for i=1,#objs do
        search(objs[i])
    end
end

return system