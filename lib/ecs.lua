---@class world_t
---@field entities table
---@field systems table
---@field plugins table
---@field add_system fun(w:world_t,sys:system_t)
---@field add_entity fun(w:world_t,e:entity_t)
---@field rm_system fun(w:world_t,sys:system_t)
---@field rm_entity fun(w:world_t,e:entity_t)
---@field update fun(w:world_t)
---@field destroy fun(w:world_t)

---@class entity_t
---@field __dirty bool
---@field __world world_t
---@field add_component fun(e:entity_t,k,v)
---@field rm_component fun(e:entity_t,k)

---@class system_t
---@field __id number
---@field __entities table
---@field __world world_t
---@field __active bool
---@field __dirty bool
---@field init fun(sys:system_t)
---@field filter fun(e:entity_t)
---@field join fun(sys:system_t,e:entity_t)
---@field exit fun(sys:system_t,e:entity_t)
---@field refresh fun(sys:system_t)
---@field pre_update fun(sys:system_t)
---@field update fun(sys:system_t)
---@field post_update fun(sys:system_t)
---@field destroy fun(sys:system_t)

local pairs=pairs
local ipairs=ipairs
local tremove=table.remove
local tinsert=table.insert
local setmetatable=setmetatable
local getmetatable=getmetatable
local rawset=rawset
local ecs={}


local function entity_add_component(t,k,v)
    print("ecs.entity",t,"add component",k)
    t.__components_added[k]=v or {}
    if t.__dirty then return end
    t.__world:update_entity(t)
end
local function entity_rm_component(t,k)
    print("ecs.entity",t,"rm component",k)
    t.__components_removed[k]=true
    if t.__dirty then return end
    t.__world:update_entity(t)
end
local function entity_get_component(t,k)
    return t[k] or t.__component_cached[k]
end
local function entity_destroy(t)
    t.__world:rm_entity(t)
end

local function entity_new(world,t)
    local t=t or {}
    local id=world._entity_counter
    world._entity_counter=id+1
    local mt={
        __id=id,
        __dirty=true,
        __world=world,
        __components_added={},
        __components_removed={},
        __components_cached={},
        add_component=entity_add_component,
        rm_component=entity_rm_component,
        get_component=entity_get_component,
        destroy=entity_destroy,
    }
    mt.__index=mt
    return setmetatable(t,mt)
end

local function system_update_entity(sys,obj)
    local filter=sys.filter
    if filter then
        local cache=sys.__entities
        if filter(obj) then
            if not cache[obj] then
                sys.__dirty=true
                tinsert(cache,obj)
                cache[obj]=#cache
                print('ecs.system',obj,"join system",sys.__name)
                if sys.join then 
                    sys:join(obj)
                end
            end
        else 
            local x=cache[obj] if x then
                local y=#cache;local tmp=cache[y]
                cache[x],cache[tmp]=tmp,x
                cache[y],cache[obj]=nil,nil
                sys.__dirty=true
                print('ecs.system',obj,"exit system",sys.__name)
                if sys.exit then 
                    sys:exit(obj) 
                end
            end
        end
    end
end
local function system_rm_entity(sys,obj)
    local cache=sys.__entities
    local i=cache[obj] if i then
        local last=#cache
        cache[cache[last]]=i
        cache[i],cache[last]=cache[last],cache[i]
        cache[last],cache[obj]=nil,nil
        sys.__dirty=true
        if sys.exit then sys:exit(obj) end
    end
end
local function system_new(world,t)
    local t=t or {}
    local mt={
        __id=-1,
        __entities={},
        __world=world,
        __active=true,
        __dirty=false,
    }
    mt.__index,mt.__newindex=mt,mt
    return setmetatable(t,mt)
end

local function world_add_entity(t,v)
    if v.__world then return v end
    v=entity_new(t,v)
    tinsert(t._entity_changes,v) 
    return v
end
local function world_update_entity(t,v) 
    getmetatable(t).__dirty=true
    tinsert(t._entity_changes,v) 
end
local function world_rm_entity(t,v) tinsert(t._entity_removed,v) end
local function world_add_system(t,v,name) 
    if v.__world then return v end
    name=name or "system"
    v=system_new(t,v)
    v.__name=name
    tinsert(t._system_added,v) 
    print("ecs.world",t,"add system",v.__name)
    return v
end
local function world_rm_system(t,v) tinsert(t._system_removed,v) end

local function world_update_entities(t)
    local changes=t._entity_changes
    local removed=t._entity_removed
    if #changes==0 and #removed==0 then return end
    t._entity_changes,t._entity_removed={},{}
    local objs=t.entities
    local syss=t.systems
    -- change entity
    for i=1,#changes do 
        local obj=changes[i]
        if not objs[obj] then 
            tinsert(objs,obj) 
            objs[obj]=#objs
        end

        local __added=obj.__components_added
        local __removed=obj.__components_removed
        local __cached=obj.__components_cached
        getmetatable(obj).__dirty=false
        for k,v in pairs(__added) do 
            obj[k]=v
            __added[k]=nil 
        end
        for k,v in pairs(__removed) do 
            __cached[k]=obj[k]
            obj[k]=nil
            __removed[k]=nil 
        end
        for j=1,#syss do system_update_entity(syss[j],obj) end
        for k,v in pairs(__cached) do __cached[k]=nil end
    end

    -- remove entity
    for i=1,#removed do 
        local obj=removed[i]
        local x=objs[obj] 
        local y=#objs
        if x then
            objs[x],objs[y]=objs[y],objs[y]
            objs[y],objs[obj]=nil,nil
            local __cached=obj.__components_cached
            for k,v in pairs(obj) do __cached[k]=v end
            for j=1,#syss do system_rm_entity(syss[j],obj) end
        end
        removed[i]=nil
        setmetatable(obj,nil)
    end

end
local function world_update_systems(t)
    local added=t._system_added
    local removed=t._system_removed
    if #added==0 and #removed==0 then return end
    local objs=t.entities
    local syss=t.systems
    -- remove system
    for i=1,#removed do 
        local sys=removed[i]
        if syss[sys] then
            local idx=sys.__id
            tremove(syss,idx)
            for j=idx,#syss do syss[i]._id=j end
            if sys.finish then sys:finish(t) end
            setmetatable(sys,nil)
        end
        removed[i]=nil
    end
    -- add system
    for i=1,#added do 
        local sys=added[i]
        tinsert(syss,sys)
        sys.__id=#syss
        added[i]=nil
        if sys.init then sys:init(t) end

        local cache=sys.__entities
        local join=sys.join 
        local filter=sys.filter
        if filter then
            for j=1,#objs do local obj=objs[j]
                if filter(obj.__components) then
                    tinsert(cache,obj)
                    if join then join(sys,obj) end
                end
            end
        end
    end
end
local function world_update(t)
    world_update_systems(t)
    world_update_entities(t)
    local syss=t.systems
    for i=1,#syss do local sys=syss[i]
        if sys.__active then 
            if sys.__dirty and sys.modify then sys:modify() end
            if sys.pre_update then sys:pre_update() end
        end
    end
    for i=1,#syss do local sys=syss[i]
        if sys.__active then 
            if sys.update then sys:update() end
        end
    end
    for i=1,#syss do local sys=syss[i]
        if sys.__active then 
            if sys.post_update then sys:post_update() end
        end
    end
end

--@TODO destroy world
local function world_destroy(t) end

local world_mt={
    __index={
        add_entity=world_add_entity,
        update_entity=world_update_entity,
        rm_entity=world_rm_entity,
        add_system=world_add_system,
        rm_system=world_rm_system,
        update=world_update,
        destroy=world_destroy,
    }
}
---@return world_t
local function new_world()
    local t={
        entities={},
        systems={},
        datas={},

        _entity_changes={},
        _entity_removed={},
        _system_added={},
        _system_removed={},
        _entity_counter=0,
    }
    print("ecs.world","new world:",t)
    return setmetatable(t,world_mt)
end

ecs.new_world=new_world

return ecs