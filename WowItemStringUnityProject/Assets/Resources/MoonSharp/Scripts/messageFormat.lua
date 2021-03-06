CmdPattern = "|%w"
ColorCmd = "|c"
RevertColorCmd = "|r"
HyperLinkBeginCmd = "|H"
HyperLinkEndCmd = "|h"

ColorPattern = ColorCmd .. string.rep("%x", 8)
RevertColorPattern = "|r"
HyperLinkPattern = "|H.-%[.-%]|h"
JsonObjectPattern = "%b{}"
ItemStringPattern = "item:" .. JsonObjectPattern
ItemLinkPattern = ColorCmd .. HyperLinkBeginCmd .. ItemStringPattern .. HyperLinkEndCmd .. RevertColorCmd
PlayerStringPattern = "player:" .. JsonObjectPattern

-- return: 1 - ok, 0 - failed matching
function IsMatching(messageString, patternID)
    if patternID == "colorPattern" then if string.match(messageString, ColorPattern) then return 1 end end
    if patternID == "revertColorPattern" then if string.match(messageString, RevertColorPattern) then return 1 end end
    if patternID == "hyperLinkPattern" then if string.match(messageString, HyperLinkPattern) then return 1 end end   
    if patternID == "itemStringPattern" then if string.match(messageString, ItemStringPattern) then return 1 end end
    if patternID == "playerStringPattern" then if string.match(messageString, PlayerStringPattern) then return 1 end end   

    return 0
end

-- 컬러 포멧으로 부터 a, r, g, b 의 정수 값을 얻는다.
-- return: 올바른 컬러 포멧이 아니면 0, 0, 0, 0 return
function GetARGBFromColorFormat(colorFormat)
    local colorHexString = string.match(colorFormat, ColorCmd .. "(" .. string.rep("%x", 8) .. ")")

    return GetARGBFromColorHexString(colorHexString)	
end

function GetARGBFromColorHexString(colorHexString)
    local a, r, g, b = string.match(colorHexString, string.rep("(%x%x)", 4))
    if a == nil then
        return 0, 0, 0, 0
    end

    return tonumber("0x" .. a), tonumber("0x" .. r), tonumber("0x" .. g), tonumber("0x" .. b)
end

-- 아이템 문자열 포멧으로 부터 정보들을 얻는함수
function GetInfosFromItemStringFormat(itemString)
    local itemInfosJsonString = string.match(itemString, "item:(" .. JsonObjectPattern .. ")")

    return itemInfosJsonString
end

function GetInfosFromPlayerStringFormat(playerString)
    local playerInfosJsonString = string.match(playerString, "player:(" .. JsonObjectPattern .. ")")

    return playerInfosJsonString
end

-- 하이퍼 링크 포멧으로 부터 정보들을 얻는함수
-- return: linkString, linkText
function GetInfosFromHyperLinkFormat(messageString)
    local linkString, linkText = string.match(messageString, HyperLinkBeginCmd .. "(.+)%[(.-)%]" .. HyperLinkEndCmd)	

    return linkString, linkText
end

-- 메세지 문자열을 메세지 문맥 문자열로 나눈다.
-- return: 메세지 문맥 문자열 리스트를 table 타입으로 리턴
function TokenizeMessageStringToMessageContextString(messageString)
    local messageContextStringList = {}

    local workIndex = 0
    local searchCmdIndex = 0
    for beginIndex, cmd, nextIndex in string.gmatch(messageString, "()(" .. CmdPattern .. ")()", searchCmdIndex) do
        --print(beginIndex .. ":" .. cmd .. ":" .. nextIndex)
        if (function()
            local cmdContextString = ""

            if cmd == ColorCmd then
                local colorCmdBeginIndex, cmdString, colorCmdNextIndex = string.match(messageString, "()("..ColorPattern..")()", beginIndex)
                if colorCmdBeginIndex ~= beginIndex then
                    searchCmdIndex = nextIndex
                    return
                else
                    searchCmdIndex = colorCmdNextIndex
                    cmdContextString = cmdString
                end
            elseif cmd == RevertColorCmd then
                searchCmdIndex = nextIndex
                cmdContextString = cmd
            elseif cmd == HyperLinkBeginCmd then
                local hyperLinkBeginIndex, cmdString, hyperLinkNextIndex = string.match(messageString, "()(".."|H.-%[.-%]|h"..")()", beginIndex)
                if hyperLinkBeginIndex ~= beginIndex then
                    searchCmdIndex = nextIndex
                    return
                else
                    searchCmdIndex = hyperLinkNextIndex
                    cmdContextString = cmdString
                end
            else
                searchCmdIndex = nextIndex
                return
            end

            -- finded cmd
            --if workIndex < beginIndex then
                ---- add before context string
                --print("in loop add at " .. #messageContextStringList + 1)
                --messageContextStringList[#messageContextStringList + 1] = string.sub(messageString, workIndex, beginIndex - 1)
                --workIndex = beginIndex
            --end

            -- add cmd context string
            --print("in loop add2 at " .. #messageContextStringList + 1)
            messageContextStringList[#messageContextStringList + 1] = cmdContextString
            workIndex = searchCmdIndex

            return
        end)() then break end
    end

    if workIndex <= string.len(messageString) then
        --print("add at " .. #messageContextStringList + 1)
        messageContextStringList[#messageContextStringList + 1] = string.sub(messageString, workIndex)
    end

    return messageContextStringList
end

-- test code
if debug.getinfo(1).what == "main" and debug.getinfo(1).short_src == arg[0] then
    local messageString = [=[|cff969696|Hitem:{"id":170000,"needLv":6,"soulcoreMaxLv":0,"bindInfo":{"unbindableCount":100,"bindType":0},"duration":{"maxDuration":100,"duration":100},"strengtheningStep":0,"quality":0,"properties":[{"id":0,"value":0},{"id":1,"value":0},{"id":2,"value":0},{"id":3,"value":0},{"id":4,"value":0},{"id":5,"value":0},{"id":6,"value":0},{"id":7,"value":0},{"id":8,"value":0},{"id":9,"value":0}]}[Legend Sword]|h|r]=]

    print("message: \n" .. messageString)

    --print(GetInfosFromHyperLinkFormat(messageString))

    print("\nTokenize result:")
    local messageContextStringList = TokenizeMessageStringToMessageContextString(messageString)
    for i, messageContextString in ipairs(messageContextStringList) do
        print(i .. ": " .. messageContextString)
    end

    print("Hit any key to close this window..") ; io.read()
end
