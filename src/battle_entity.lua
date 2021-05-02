local meta=require "battle_meta"
local malloc=__malloc
local entity={}

function entity.new_unit()
    local t={
        identity=malloc(meta.identity_t),
        transform=malloc(meta.transform_t),
        renderer=malloc(meta.renderer_t),
        property={
            template=malloc(meta.property_t),
            static=malloc(meta.property_t),
            dynamic=malloc(meta.property_t),
        },
        state=malloc(meta.state_t),
        ai_state=malloc(meta.ai_state_t),
    }
    return t
end

return entity