local ecs=require "ecs"

local context={}
local _current_context
local context_mt={
    __call=function(t)return _current_context end
}
context=setmetatable(context,context_mt)

function context.new(argv,sysv)
    local world=ecs.new_world()
    local t={
        world=world,
        alive_units=nil,
        dead_units=nil,
        
        tickstamp=0,
    }
    for i=1,#sysv do
        local name=sysv[i]
        local sys=require(name)
        world:add_system(sys,name)
    end
    _current_context=setmetatable(t,{__index=context})
    return _current_context
end

function context:update()
    _current_context=self
    self.tickstamp=self.tickstamp+1
    self.world:update()
end

return context