--[[
    http
]]

http = http or {}

function http.download(url, path, tp)
    assert(string.valid(url))
    assert(string.valid(path))
    tp = tp or 'wget'
    local folder = files.get_folder(path)
    files.mk_folder(folder)
    local cmd = nil
    local isOk = false
    if tp == 'curl' then
        cmd = [[curl -L "%s" -o "%s" --max-redirs 3]]
    elseif tp == 'wget' then
        cmd = [[wget "%s" -O "%s"]]
    end
    cmd = string.format(cmd, url, path)
    local isOk, output, code = tools.execute(cmd)
    return isOk, output, code, cmd
end

local function curl_request(url, method, params, headers)
    --
    local httpContentFile = "./.lua.http.log"
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
    if method == "GET" then
        for k,v in pairs(params) do
            if not string.find(url, "?") then url = url .. "?" end
            assert(is_string(k))
            assert(is_string(v) or is_number(v))
            url = url .. tostring(k) ..  "=" .. tostring(v)
        end
    elseif method == "POST" then
        b = string.format("-d '%s'", json.encode(params))
    end
    --
    local cmd = [[curl "%s" -i  --silent -o "%s" -X %s "%s" -d "%s"]]
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
    local code, content = curl_request(url, method, params, headers)
    return code == 200, code, content
end

function http.get(url, params, headers)
    return http_request(url, 'GET', params, headers)
end

function http.post(url, params, headers)
    return http_request(url, 'POST', params, headers)
end
