local planner=require "planner"

local PRIORITY={
    LOW=1<<1,
    HIGH=1<<2,
    INTERRUPT=1<<3,
}
local function cmp(c0,c1) return c0<c1 end

local flags={
    "DEAD",
    "HURT",
    "CAN_ATTACK",
    "HAS_ATTACK_TARGET",
}

local actions={
    action_die={
        priority=PRIORITY.INTERRUPT|PRIORITY.HIGH,
        cost=-1,
        preconditions={
            DEAD=true,
        },
    },
    action_idle={
        priority=PRIORITY.LOW,
        cost=3,
        preconditions={
            DEAD=false,
        },
    },
    action_attack={
        priority=PRIORITY.HIGH,
        cost=2,
        preconditions={
            CAN_ATTACK=true,
            HAS_ATTACK_TARGET=true,
        },
    },
    action_search={
        priority=PRIORITY.HIGH,
        cost=1,
        preconditions={
            CAN_ATTACK=true,
            HAS_ATTACK_TARGET=false,
        },
    },
    action_hurt={
        priority=PRIORITY.LOW,
        cost=1,
        preconditions={
            HURT=true,
        },
    }
}

return planner.new("ai_unit_autocombat",flags,actions,cmp)