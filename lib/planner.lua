local planner={}
planner.__index=planner

local function valueof(mapping,state)
    local val,mask=0,-1
    for k,v in pairs(state) do
        local tmp=mapping[k]
        val=v and val|tmp or val& ~tmp
        mask=mask& ~tmp
    end
    return val,mask
end

local function build_mapping(flags)
    for i=1,#flags do
        flags[flags[i]]=1<<i
    end
    return flags
end

--1state_val 2state_mask 3value 4cost 5priority
local function build_actions(flags,actions)
    local act={}
    for k,v in pairs(actions) do
        local val,mask=valueof(flags,v.preconditions)
        act[k]={
            val,mask,
            v.value or 0,
            v.cost or 0,
            v.priority or 0,
        }
    end
    return act
end

function planner.new(
    name, --ai name
    flags, --condition flags table
    actions, --action table
    priority --behaviour priority cmp function
)
    local mapping=build_mapping(flags)
    local t={
        _name=name,
        _flags=mapping,
        _actions=build_actions(mapping,actions),
        _priority=priority
    }
    return setmetatable(t,planner)
end

function planner:exchange(act0,act1)
    local a0=self._actions[act0][5]
    local a1=self._actions[act1][5]
    return self._priority(a0,a1)
end

local _matchs={}
function planner:plan(state)
    local val,mask=valueof(self._flags,state)
    local count=0
    for k,v in pairs(self._actions) do
        local care=v[2]~ (-1)
        if (val&care)==(v[1]&care) then
            count=count+1
            _matchs[count]=k
        end
    end
    local name if count>0 then
        local cost=1<<31
        for i=1,count do 
            local match=_matchs[i]
            local act=self._actions[match]
            local _cost=act[4]
            if _cost<=cost then
                cost=_cost
                name=match
            end
        end
    end
    return name
end

return planner
