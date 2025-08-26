--!strict

local module = {}

-- this module handle ALL logics for ALL systems in the game.

local observer = require(script.Parent.observer)

--change name to ted or something, something unique
local core = workspace:FindFirstChild('core', true)

if not core then
    return
end

module.loop = nil :: thread | nil
module.loop_speed_seconds = 1

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
    print('core has folded like a chair.')
end, true)

function module.set_core_stage(stage_number : number)
    local stage = module.core_stages[stage_number]

    if stage then
        stage.run()
    end
end

function module._loop()
    while task.wait(module.loop_speed_seconds) do
        
    end
end

function module.init()
    module.set_core_stage(0)
    module.loop = task.spawn(module._loop)
end

module.init()

return module

