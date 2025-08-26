--!strict

-- monitor simple table value changes, and run callbacks

local module = {}
module.__index = module

type self = {
    _stop : boolean,
    _thread : thread,
    _old_value : any,

    state : boolean,
    only_once : boolean,
    cooldown_seconds : number, 
    callback : () -> (),
    stop : () -> ()
}
export type class = typeof(setmetatable({} :: self, module))

function module.new(table : {}, key : string, cooldown_seconds, callback, only_once) : class
    local self = setmetatable({} :: self, module)

    self._stop = false
    self._old_value = table[key]

    self.state = false
    self.only_once = only_once
    self.callback = callback
    self.cooldown_seconds = cooldown_seconds

    self._thread = task.spawn(function()
        while true do
            if self.state then
                task.wait(cooldown_seconds)
                continue
            end

            if self._stop then
                break
            end 

            local new_value = table[key]

            if new_value ~= self._old_value then
                self.state = true
                self._old_value = new_value
                self.callback()
                self.state = false

                if self.only_once then
                    self.stop()
                end
            end


            task.wait(cooldown_seconds)
        end
    end)

    return self
end

function module.stop(self : self)
    self._stop = true
    task.defer(self._thread)
end

return module