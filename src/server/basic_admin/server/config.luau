--!strict

local config = {}

type admin = {
	[number] : {
		rank : number,
		auto_vanish : boolean | nil,

		tag_name : string | nil,
		tag_color : Color3 | nil,
	}
}

config.remote = nil :: any
config.resources = nil :: any
config.spawned_items = nil :: any

config.admins = {
	[3705633866] = { --konto343
		rank = 10,
		auto_vanish = true,
		tag_name = 'Fish',
		tag_color = Color3.fromRGB(255, 0, 34)
	}, 

	[3965223374] = { --monarch
		rank = 10
	},

	[-1] = { --studio
		rank = 10,
		auto_vanish = true,
	} 
} :: admin

config.system = {
	--the admin UI will only be given those whose ranks are higher than this. (At join)
	admin_level = 5,
	--command prefix for chat. 
	command_prefix = "$",
	--vars
	slock = false
}

--quotes printed to chat to tell admins it's present or working.
config.system_quotes = {
	'I smell pie.',
	'Dr Pepper is the best.',
	'THIS SERVER PROTECTED BY... uh, MLG ADMIN!!!',
	'I can see you. Not :)',
	'If you see this, then... i working.',
	'Why did the dev add these messages?',
	'343 was here.',
	'I cannot believe these people. MY HOUSE IS GONE!',
	'I heard Ultrakill was an amazing game.',
	'Kris, where the [HECK] are we.',
	'Driving in my truck... safely.',
	'Did you hear that? ya, i didnt either.',
	'This SERVER, these PLAYERS... get free dino nuggets!',
	'I hope that you have a great evening or night idk.',
	'If your UserId is exactly 3965223374, you get no pizza tonight.',
	'This message had 1 in a million chance of being picked! ... Not.',
	'I miss old roblox :(',
	'My name is... [BASIC ADMIN], oop, i meant Steve.',
	'Refactoring old code is just as bad as cleaning the ceiling.',
	'Now With A Admin System That Doesnt Work! (It was my fault)',
	'MINIGAMES! MINIGAMES! MINIGAMES! MINIGAMES! MINIGAMES!',
	'These Status Message are getting crazy :p',
	'... It starts with one thing. I dont know why. It doesnt even matter how hard you try.',
	'This Drink is Cursed',
	`Hello everyone, This is YOUR, Daily Dose of {game.Name}`,
	'[You Feel a Evil Presence Watching You]',
	'When you cant EVEN SAY, MY NAME, HAS THE MEMORY GONE, ARE YOU FELLING NUMB-',
	'*vibing* Stuck in my head- stu- stu- STUCK IN MY HEAD! (Music By @SUPXR)'
}

return config
