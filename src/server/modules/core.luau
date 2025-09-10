--!strict

local module = {}

-- this module handle ALL logics for ALL systems (for the core) in the game.

local observer = require(script.Parent.observer)

--change name to ted or something, something unique
--also if this fails to be found, the universe collaspes
local core = workspace:FindFirstChild('core', true)
assert(core, 'Core is MISSING!??!?!?')

module.loop = nil :: thread | nil
module.loop_speed_seconds = .1

module.core_expo = 3 --exponet
module.power_out = 0

-- events
module.events = {
    core_start_up = false,
    core_shutdown_up = false,

    -- overcharge ("""meltdown""")
    core_stage_1 = false,
    core_stage_2 = false,
    core_stage_3 = false,

    emergency_fold = false,
    emergency_eject = false,
    emergency_dip = false
}

-- core
module.core = {
    status = false,
    temperature = 0,
    pressure = 0,
    radiation = 0
}

-- for mirror array
module.mirror_array = {
    _coolant_max = 1000,
    _coolant = 0,
    coolant_intake = false,
    coolant_out = false,
    focus_length = 0 --how much power to absorb
}

-- rings (scales power output, very delicate)
module.rings = {
    rings_speed = 0,
    ring1_state = false,
    ring2_state = false,
    ring3_state = false,
    ring4_state = false
}

module.core_stages = {
    [0] = { --basically a reset
        temp_requirement = nil,
        run = function()

        end
    },

    [1] = {
        temp_requirement = 4000,
        run = function()

        end
    },

    [2] = {
        temp_requirement = 6000,
        run = function()

        end
    },

    [3] = {
        temp_requirement = 9000,
        run = function()

        end
    },
} :: {
    [number] : {
        temp_requirement : number | nil,
        run : () -> ()
    }
}

observer.new(module.events, 'emergency_fold', 1, function()
    --nothing
end, true)

function module.set_core_stage(stage_number : number)
    local stage = module.core_stages[stage_number]

    if stage then
        stage.run()
    end
end

--runs only while core is active
function module._loop()
    while task.wait(module.loop_speed_seconds) do
        if not module.core.status then
            continue
        end

        local ring_factor = (
            (module.rings.ring1_state and 1 or -.1) * module.rings.rings_speed +
             (module.rings.ring2_state and 1 or -.1) * module.rings.rings_speed +
              (module.rings.ring3_state and 1 or -.1) * module.rings.rings_speed +
               (module.rings.ring4_state and 1 or -.1) * module.rings.rings_speed
        ) 
        -- ring_factor - 4 <= x >= -.4
        -- rings_speed - 0 <= 10 >= 100
        
        local coolant_factor = math.clamp(
            module.mirror_array._coolant, 
            0,
            module.mirror_array._coolant_max
        )
        
        if module.mirror_array.coolant_intake then
            module.mirror_array._coolant += 1
        end

        if module.mirror_array.coolant_out then
            module.mirror_array._coolant -= 1
        end

        module.core.temperature = (
            (ring_factor / module.mirror_array.focus_length) ^ module.core_expo
        ) + (module.core.radiation / module.core_expo)

        module.power_out = (
            (module.core.temperature * module.mirror_array.focus_length) / coolant_factor
        )
    end
end

function module.reset()
    --whatever
    return 'apple'
end

function module.init()
    module.set_core_stage(0)
    module.loop = task.spawn(module._loop)
end

module.init()

return module

