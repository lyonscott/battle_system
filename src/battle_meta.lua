local meta={}

meta.transform_t={
    position={},
    scale=1,
    angle=0,
}

meta.renderer_t={
    id=0,
    url="",
    layer=1,
}

meta.animation_t={
    name="",
    time_scale=1,
    is_loop=false,
}

meta.identity_t={
    id=0,
    name="",
    config_id=0,
    team_id=0,
    owner_id=0,
}

meta.property_t={
    health=0,
    min_health=0,
    mana=0,
    attack_damage=0,
    armor=0,
    attack_interval=0,
    incoming_physical_damage_effect=1,
    outgoing_physical_damage_effect=1,
}

meta.dynamic_property_t={
    health=0,
    mana=0,
    attack_interval=0,
}

meta.state_t={
    stunned=false,
    attack_immune=false,
    silenced=false,
    disarmed=false,
    invulnerable=false,
    unstoppable=false,
}

meta.ai_state_t={
    DEAD=false,
    HURT=false,
    CAN_ATTACK=false,
    HAS_ATTACK_TARGET=false,
}

return meta