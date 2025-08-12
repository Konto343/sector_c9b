--!strict

local text_chat = game:GetService('TextChatService')
local message : string = script:GetAttribute('message')
local color : Color3 = script:GetAttribute('color')

local system : TextChannel = text_chat.TextChannels:WaitForChild('RBXSystem', 10)
system:DisplaySystemMessage(
    `<b><font color='#{color:ToHex()}'>{message}</font></b>`
)

script:Destroy()