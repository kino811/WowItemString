require("messageFormat")

----------------------------------------
MessageContext = {
   text = ""
}

function MessageContext:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self

   o:Init(o[1] or "")
   
   return o
end

function MessageContext:Init(messageString)
end

function MessageContext:GetText()
   return self.text
end

function MessageContext:ProcessForPrintToMessageFrame(messageFrame)
   assert(nil, "need overriding")
end
----------------------------------------
TextMessageContext = MessageContext:new{
   
}

function TextMessageContext:Init(messageString)
   self.text = messageString
end

function TextMessageContext:ProcessForPrintToMessageFrame(messageFrame)
   messageFrame:PrintText(self:GetText())
end
----------------------------------------
ColorMessageContext = MessageContext:new{
   color = "ffffffff"
}

function ColorMessageContext:Init(messageString)
   self.text = ""
   self.color = string.match(messageString, string.rep("%x", 8))
end

function ColorMessageContext:ProcessForPrintToMessageFrame(messageFrame)
   messageFrame:SetTextColor(self.color)
end
----------------------------------------
RevertColorMessageContext = MessageContext:new{
}

function RevertColorMessageContext:Init(messageString)
   self.text = ""
end

function RevertColorMessageContext:ProcessForPrintToMessageFrame(messageFrame)
   messageFrame:SetTextColor(messageFrame:GetTextDefaultColor())
end
----------------------------------------
HyperLinkMessageContext = MessageContext:new{
   dataString = "",
}

function HyperLinkMessageContext:Init(messageString)
   local dataString, text = string.match(messageString, "|H(.-)(%b[])|h")
   --print(text)

   self.text = string.match(text, "%[(.+)%]")
   --print(self.text)
   self.dataString = dataString
end

function HyperLinkMessageContext:ProcessForPrintToMessageFrame(messageFrame)
   messageFrame:PrintText(self:GetText())
end
----------------------------------------
Message = {
   messageContexts = nil
}

function Message:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self

   o.messageContexts = o.messageContexts or {}

   return o
end

function Message:AddMessageString(messageString)
   if string.match(messageString, HyperLinkPattern) then
      newMessageContext = HyperLinkMessageContext:new{messageString}
   elseif string.match(messageString, ColorPattern) then
      newMessageContext = ColorMessageContext:new{messageString}
   elseif string.match(messageString, RevertColorPattern) then
      newMessageContext = RevertColorMessageContext:new{messageString}
   else
      newMessageContext = TextMessageContext:new{messageString}
   end
   
   self.messageContexts[#self.messageContexts + 1] = newMessageContext
end

function Message:GetText()
   local t = {}

   for i, messageContext in ipairs(self.messageContexts) do
      if messageContext ~= "" then
	 t[#t + 1] = messageContext:GetText()
      end
   end

   return table.concat(t)
end

function Message:PrintToMessageFrame(messageFrame)
   for i, messageContext in ipairs(self.messageContexts) do
      messageContext:ProcessForPrintToMessageFrame(messageFrame)
   end
end
----------------------------------------
MessageFrame = {
   messageBuffer = nil,
   textDefaultColor = "ffffffff",
   textColor = "ffffffff",
}

function MessageFrame:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self

   o.messageBuffer = o.messageBuffer or {}
   o.textColor = o.textDefaultColor

   return o
end

function MessageFrame:AddMessage(messageString, begining)
   begining = begining or false
   if (not begining and #self.messageBuffer == 0) then
       begining = true
   end

   local targetMessage = nil

   if begining then
      -- add new message
      targetMessage = Message:new{}
      self.messageBuffer[#self.messageBuffer + 1] = targetMessage
   else
      -- add message to last message by messageContext
      targetMessage = self.messageBuffer[#self.messageBuffer]
   end

   targetMessage:AddMessageString(messageString)
end

function MessageFrame:PrintMessages(messageLineGap)
    messageLineGap = messageLineGap or 0

    for i, message in ipairs(self.messageBuffer) do
        message:PrintToMessageFrame(self)

        for i = 1, messageLineGap do
            print()
        end
    end
end

function MessageFrame:PrintText(text)
   print(text)
end

function MessageFrame:SetTextColor(color)
    self.textColor = color
end

function MessageFrame:GetTextDefaultColor()
   return self.textDefaultColor
end

function MessageFrame:GetTextFromMessageString(messageString)
   local messageContextStringList = TokenizeMessageStringToMessageContextString(messageString)

   for i, messageContextString in ipairs(messageContextStringList) do
      self:AddMessage(messageContextString, i == 1 and true or false)
   end

   local t = {}

   for i, message in ipairs(self.messageBuffer) do
      local messageText = message:GetText()
      if messageText ~= "" then
          t[#t + 1] = message:GetText()
      end
   end

   return table.concat(t)
end
----------------------------------------
function ParseMessageString(messageString, messageFrame)
   local messageContextStringList = TokenizeMessageStringToMessageContextString(messageString)
   for i, messageContextString in ipairs(messageContextStringList) do
      --print(messageContextString)
      messageFrame:AddMessageContextString(messageContextString, i == 1 and true or false)
   end	
end

function GetTextFromMessageString(messageString)
   local msgFrame = MessageFrame:new{}	

   return msgFrame:GetTextFromMessageString(messageString)
end

----------------------------------------

-- testing codes
if debug.getinfo(1).what == "main" and debug.getinfo(1).short_src == arg[0] then
    local msgFrame = MessageFrame:new{}

    msgFrame:AddMessage("This is test.")

    msgFrame:AddMessage("ItemLink: ", true)
    msgFrame:AddMessage([[|Hitem:{"id":100, "grade":"normal"}[ItemA]|h]])

    msgFrame:AddMessage("Test end", true)

    msgFrame:PrintMessages()
    print("--------------------")
    msgFrame:PrintMessages(1)
    print("--------------------")

   print(GetTextFromMessageString([=[|cff969696|Hitem:{"id":170000,"needLv":6,"soulcoreMaxLv":0,"bindInfo":{"unbindableCount":100,"bindType":0},"duration":{"maxDuration":100,"duration":100},"strengtheningStep":0,"quality":0,"properties":[{"id":0,"value":0},{"id":1,"value":0},{"id":2,"value":0},{"id":3,"value":0},{"id":4,"value":0},{"id":5,"value":0},{"id":6,"value":0},{"id":7,"value":0},{"id":8,"value":0},{"id":9,"value":0}]}[Legend Shield]|h|r]=]))

   print("Hit any key to close this window..") ; io.read()
end
