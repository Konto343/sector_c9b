local module = {}

export type self = {
    _locked : boolean,
    state : boolean,

    attributes : {
        [string] : any
    },

    events : {
        RBXScriptConnection
    },

    set : (...any) -> (),
    set_state : (value : boolean) -> (),
    lock : (...any) -> (),
    init : (...any) -> () | nil,
    at_set : (...any) -> () | nil,
    at_lock : (value : boolean) -> () | nil,
}

return module