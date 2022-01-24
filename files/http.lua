--[[
    http
]]

local http = {}

function http.download(url, path, tp)
    assert(string.valid(url))
    assert(string.valid(path))
    tp = tp or 'wget'
    local folder = files.get_folder(path)
    files.mk_folder(folder)
    local cmd = nil
    local isOk = false
    if tp == 'pws1' then
        cmd = "powershell (new-object Net.WebClient).DownloadFile('%s', '%s')"
    elseif tp == 'curl' then
        cmd = "curl '%s' >> '%s'"
    elseif tp == 'wget' then
        cmd = "wget '%s' -O '%s'"
    end
    cmd = string.format(cmd, url, path)
    local isOk, output = tools.execute(cmd)
    return isOk, output, cmd
end

local function pws_request(url, method, params, headers)
    -- 
    local httpCodeFile = './lua.http.code.log'
    local httpContentFile = './lua.http.content.log'
    files.delete(httpCodeFile)
    files.delete(httpContentFile)
    --
    local hc = ""
    for k,v in pairs(headers) do
        assert(is_string(k))
        assert(is_string(v) or is_number(v))
        if hc ~= "" then
            hc = hc .. ";"
        end
        hc = hc .. tostring(k) .. "=" .. tostring(v)
    end
    local h = string.format("@{%s}", hc)
    -- 
    local pc = ""
    for k,v in pairs(params) do
        assert(is_string(k))
        assert(is_string(v) or is_number(v))
        if pc ~= "" then
            pc = pc .. ";"
        end
        pc = pc .. tostring(k) .. "=" .. tostring(v)
    end
    local p = string.format("@{%s}", pc)
    --
    local cmd = "try { "
    cmd = cmd .. "$response = (Invoke-WebRequest -Uri %s -Method %s -Headers %s -Body %s);"
    cmd = cmd .. "$result = $response;"
    cmd = cmd .. "$code = $response.StatusCode;"
    cmd = cmd .. " } catch { "
    cmd = cmd .. "$result = $_.ErrorDetails.Message;"
    cmd = cmd .. "$code = $_.Exception.response.StatusCode.value__;"
    cmd = cmd .. "}"
    cmd = cmd .. string.format("Set-Content %s $code;", httpCodeFile)
    cmd = cmd .. string.format("Set-Content %s $result;", httpContentFile)
    cmd = string.format("powershell -Command %s", cmd)
    cmd = string.format(cmd, url, method, h, p)
    local isOk, output = tools.execute(cmd)
    local code = files.read(httpCodeFile)
    code = code and tonumber(code) or -1
    local content = files.read(httpContentFile)
    files.delete(httpCodeFile)
    files.delete(httpContentFile)
    if not isOk or code < 0 then
        return -1, output
    else
        return code, content
    end
end

local function curl_request(url, method, params, headers)
    --
    local httpContentFile = "lua.http.content.log"
    files.delete(httpContentFile)
    --
    local h = ""
    for k,v in pairs(headers) do
        assert(is_string(k))
        assert(is_string(v) or is_number(v))
        if h ~= "" then
            h = h .. ";"
        end
        h = h .. "-H '" .. tostring(k) .. ":" .. tostring(v) .. "'"
    end
    --
    local b = ""
    if m == "GET" then
        for k,v in pairs(params) do
            if not string.find(url, "?") then url = url .. "?" end
            assert(is_string(k))
            assert(is_string(v) or is_number(v))
            url = url .. tostring(k) ..  "=" .. tostring(v)
        end
    elseif m == "POST" then
        b = string.format("-d '%s'", json.encode(params))
    end
    --
    local cmd = "curl '%s' -i  --silent -o '%s' -X %s '%s' -d '%s'"
    cmd = string.format(cmd, url, httpContentFile, method, h, b)
    local isOk, output = tools.execute(cmd)
    local content = files.read(httpContentFile) or ""
    files.delete(httpContentFile)
    local contents = string.explode(content, "\n%s*\n", 1)
    local head = contents[1] or ""
    local body = contents[2] or ""
    local from, to = string.find(head, 'HTTP.*%s%d%d%d')
    local code = (from and to) and tonumber(string.sub(head, to - 3, to) or "") or -1
    if not isOk or code < 0 then
        return -1, output
    else
        return code, body
    end
end

local function http_request(url, method, params, headers)
    assert(string.valid(url))
    local m = string.upper(method)
    assert(m == "POST" or m == "GET")
    params = params or {}
    headers = headers or {}
    local code = -1
    local content = "not supported"
    if tools.is_windows() then
        code, content = pws_request(url, method, params, headers)
    elseif tools.is_linux() then
        code, content = curl_request(url, method, params, headers)
    end
    return code == 200, code, content
end

function http.get(url, params, headers)
    return http_request(url, 'GET', params, headers)
end

function http.post(url, params, headers)
    return http_request(url, 'POST', params, headers)
end

return http
