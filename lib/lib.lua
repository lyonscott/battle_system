local typeof=type
local pairs=pairs

__malloc=function(t)
    local function _malloc(t)
        if typeof(t) ~= "table" then return t end
        local new_t={}
        for k,v in pairs(t) do
            new_t[k]=_malloc(v)
        end
        return new_t
    end
    t= t or {}
    return _malloc(t)
end