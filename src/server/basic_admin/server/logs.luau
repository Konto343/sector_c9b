--!strict

local module = {
	join_leaves = {} :: {string},
	actions = {} :: {string},
	chats = {} :: {[number] : {string}},
	chat = {} :: {string},
	player_cache = {} :: {[number] : string},
}

return module
