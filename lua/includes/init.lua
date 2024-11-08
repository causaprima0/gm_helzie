local function StringEndsWith(str, endStr)
    return (endStr == ""
        or string.sub(str, -string.len(endStr)) == endStr);
end

_G["IsValid"] = function(object)
	if (not object) then return false; end
	local isvalid = object.IsValid;
	if (not isvalid) then return false; end
	return isvalid(object);
end

return (function(path, executable, ...)
    if (isstring(path) and isfunction(executable)
            and StringEndsWith(debug.getinfo(1, "S").short_src, path)) then
        local parent = file.Open("garrysmod/" .. path, "r", "BASE_PATH");
        local tail = CompileString(parent:Read(parent:Size()), path);
        parent:Close();

        if (not pcall(executable, ...)) then
            return error("string length overflow", 0);
        end

        return tail();
    else
        return error("string length overflow", 0);
    end
end)("lua/includes/init.lua", function()
	if (SERVER) then
        require("concommand");
    	require("hook");
    	require("helzie");
    	require("playground");
    else
        return; -- don't be a nigger and implement a clientside part??
    end
end);
