-- diagnose.lua
print("=== 1. Speaker check ===")
local speaker = peripheral.find("speaker")
if not speaker then
    print("NO SPEAKER FOUND - check placement/attachment")
else
    print("Speaker OK, playing test note (listen now)...")
    speaker.playNote("harp", 3.0, 12)
    sleep(1)
end

print("=== 2. Noise burst test (raw playAudio) ===")
if speaker then
    local buffer = {}
    for i = 1, 128 do buffer[i] = math.random(-128, 127) end
    local ok = speaker.playAudio(buffer)
    print("playAudio returned: " .. tostring(ok) .. " (listen for static)")
    sleep(1)
end

print("=== 3. Download check ===")
local url = "https://raw.githubusercontent.com/Anatolii-Borshch/music-temp/main/fraer-krug.dfpwm"
local response = http.get(url, nil, true)
if not response then
    print("FAILED to connect to URL")
else
    local headers = response.getResponseHeaders()
    print("Content-Length: " .. tostring(headers["Content-Length"]))
    print("Content-Type: " .. tostring(headers["Content-Type"]))
    local data = response.readAll()
    print("Actual bytes read: " .. #data)
    response.close()

    print("=== 4. Decode + play first chunk ===")
    if speaker and #data > 0 then
        local dfpwm = require("cc.audio.dfpwm")
        local decoder = dfpwm.make_decoder()
        local chunk = data:sub(1, 16 * 1024)
        local decoded = decoder(chunk)
        local played = speaker.playAudio(decoded)
        print("First chunk playAudio returned: " .. tostring(played) .. " (listen now)")
    end
end
