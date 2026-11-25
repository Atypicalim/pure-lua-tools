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
    local isOk, output = tools.capture(cmd)
    return isOk, output, cmd
end

local function curl_request(url, method, params, headers)
    --
    local httpReqFile = "./.lua.http.req"
    local httpRspFile = "./.lua.http.rsp"
    files.delete(httpReqFile)
    files.delete(httpRspFile)
    --
    local h = ""
    for k,v in pairs(headers) do
        assert(is_string(k))
        assert(is_string(v) or is_number(v))
        local header = tostring(k) .. ":" .. tostring(v)
        header = string.gsub(header, "[\r\n]+", " ")
        h = h .. string.format([[ -H "%s"]], header)
    end
    --
    local b = ""
    if method == "GET" then
        local query = {}
        for k,v in pairs(params) do
            assert(is_string(k))
            assert(is_string(v) or is_number(v))
            table.insert(query, tostring(k) .. "=" .. tostring(v))
        end
        if #query > 0 then
            url = url .. (string.find(url, "?", 1, true) and "&" or "?")
            url = url .. table.concat(query, "&")
        end
    elseif method == "POST" then
        files.write(httpReqFile, json.encode(params), "wb")
        b = string.format([[--data-binary @"%s"]], httpReqFile)
    end
    --
    local cmd = [[curl "%s" -sSL --max-time 120 -o "%s" -w "%%{http_code}" -X %s%s %s]]
    cmd = string.format(cmd, url, httpRspFile, method, h, b)
    local isOk, output = tools.capture(cmd)
    local content = files.read(httpRspFile, "rb") or ""
    files.delete(httpReqFile)
    files.delete(httpRspFile)
    local code = isOk and tonumber(string.match(output, "(%d%d%d)%s*$")) or -1
    if code <= 0 then
        return code, output
    else
        return code, content
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
