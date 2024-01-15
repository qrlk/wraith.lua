require 'lib.moonloader'

script_name("wraith.lua")
script_author("qrlk")
script_description("wraith passive")
-- made for https://www.blast.hk/threads/193650/
script_url("https://github.com/qrlk/wraith.lua")
script_version("31.12.2023-rc4")

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true     -- false to disable error reports to sentry.io
-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)

--^^ none of it works if wraith.lua is loaded as a module.

--pls dont use this in your projects, I do not plan to maintain this module for a long time
local aimline = {}
do
    aimline._VERSION = "0.0.1"

    -- the aspect ratio snippet is being worked on here:  https://www.blast.hk/threads/198256/ https://github.com/qrlk/wraith-xiaomi

    -- trying to ulitize aspectRatio property from aimSync
    aimline.aspectRatios = {
        [63] = "5:4",    -- 1,25
        [85] = "4:3",    -- 1,333333333333333
        [98] = "43:18",  -- 2,388888888888889
        [127] = "3:2",   -- 1,5
        [143] = "25:16", -- 1,5625
        [153] = "16:10", -- 1,6
        [169] = "5:3",   -- 1,666666666666667
        -- [196] = "16:9 (alt)", -- 1,771084337349398
        [198] = "16:9"   -- 1,777777777777778
    }

    aimline.approximateAspectRatio = { {
        ["start"] = 63 - 11,
        ["end"] = 63 + 11,
        ["value"] = "5:4"
    }, {
        ["start"] = 85 - 11,
        ["end"] = 85 + 6.5,
        ["value"] = "4:3"
    }, {
        ["start"] = 98 - 6.5,
        ["end"] = 98 + 14,
        ["value"] = "43:18"
    }, {
        ["start"] = 127 - 14,
        ["end"] = 127 + 8,
        ["value"] = "3:2"
    }, {
        ["start"] = 143 - 8,
        ["end"] = 143 + 5,
        ["value"] = "25:16"
    }, {
        ["start"] = 153 - 5,
        ["end"] = 153 + 8,
        ["value"] = "16:10"
    }, {
        ["start"] = 169 - 8,
        ["end"] = 169 + 14.5,
        ["value"] = "5:3"
    }, {
        ["start"] = 198 - 14.5,
        ["end"] = 198 + 14.5,
        ["value"] = "16:9"
    } }

    aimline.getRealAspectRatioByWeirdValue = function(aspectRatio)
        local hit = false
        if aimline.aspectRatios[aspectRatio] ~= nil then
            hit = true
            return hit, aimline.aspectRatios[aspectRatio]
        end
        for k, v in pairs(aimline.approximateAspectRatio) do
            if aspectRatio > v['start'] and aspectRatio < v['end'] then
                return hit, v['value']
            end
        end
        return false, "unknown"
    end

    -- 2. 720x480 - Aspect Ratio: 3:2  127

    -- 1. 640x480 - Aspect Ratio: 4:3 85
    -- 4. 800x600 - Aspect Ratio: 4:3 85
    -- 5. 1024x768 - Aspect Ratio: 4:3 85
    -- 6. 1152x864 - Aspect Ratio: 4:3 85
    -- 11. 1280x960 - Aspect Ratio: 4:3 85
    -- 15. 1440x1080 - Aspect Ratio: 4:3 85
    -- 18. 1600x1200 - Aspect Ratio: 4:3 85
    -- 24. 1920x1440 - Aspect Ratio: 4:3 85

    -- 9. 1280x768 - Aspect Ratio: 5:3 169

    -- 3. 720x576 - Aspect Ratio: 5:4 63
    -- 12. 1280x1024 - Aspect Ratio: 5:4 63

    -- 7. 1176x664 - Aspect Ratio: 16:9 196
    -- 13. 1360x768 - Aspect Ratio: 16:9 196

    -- 8. 1280x720 - Aspect Ratio: 16:9 198
    -- 14. 1366x768 - Aspect Ratio: 16:9 198
    -- 16. 1600x900 - Aspect Ratio: 16:9 198
    -- 22. 1920x1080 - Aspect Ratio: 16:9 198
    -- 25. 2560x1440 - Aspect Ratio: 16:9 198

    -- 26. 3440x1440 - Aspect Ratio: 43:18 98 2,38 2,388888888888889 2,365253077975376
    -- 27. 2580x1080 - Aspect Ratio: 43:18 98

    -- 17. 1600x1024 - Aspect Ratio: 25:16 143

    -- 10. 1280x800 - Aspect Ratio: 16:10 153
    -- 21. 1680x1050 - Aspect Ratio: 16:10 153
    -- 23. 1920x1200 - Aspect Ratio: 16:10 153

    -- the aimline snipper is being worked on here: https://www.blast.hk/threads/198312/ https://github.com/qrlk/wraith-aimlined

    aimline.anglesPerAspectRatio = {
        ["5:4"] = {
            curxy = -0.04,
            curz = 0.105,
            curARxy = -0.027,
            curARz = 0.07,
            curRFxy = -0.019,
            curRFz = 0.047
        },
        ["4:3"] = {
            curxy = -0.044,
            curz = 0.109,
            curARxy = -0.03,
            curARz = 0.07,
            curRFxy = -0.019,
            curRFz = 0.047
        },

        ["43:18"] = {
            curxy = -0.079,
            curz = 0.104,
            curARxy = -0.052,
            curARz = 0.07,
            curRFxy = -0.034,
            curRFz = 0.047
        },
        ["3:2"] = {
            curxy = -0.047,
            curz = 0.105,
            curARxy = -0.033,
            curARz = 0.07,
            curRFxy = -0.022,
            curRFz = 0.048
        },
        ["25:16"] = {
            curxy = -0.049,
            curz = 0.105,
            curARxy = -0.033,
            curARz = 0.07,
            curRFxy = -0.023,
            curRFz = 0.048
        },
        ["16:10"] = {
            curxy = -0.05,
            curz = 0.105,
            curARxy = -0.036,
            curARz = 0.07,
            curRFxy = -0.024,
            curRFz = 0.047
        },
        ["5:3"] = {
            curxy = -0.052,
            curz = 0.105,
            curARxy = -0.036,
            curARz = 0.07,
            curRFxy = -0.024,
            curRFz = 0.047
        },
        ["16:9"] = {
            curxy = -0.056,
            curz = 0.104,
            curARxy = -0.037,
            curARz = 0.07,
            curRFxy = -0.026,
            curRFz = 0.047
        },

        -- need to investigate the issue with 16:9 clients without widescreenfix
        -- It’s not clear how to distinguish people with a 16:9 fix from those who don’t have it
        -- if widescreen fix is not installed but widescreen mode is enabled in the settings, the values should be like this:

        ["16:9noWSF"] = {
            curxy = -0.043,
            curz = 0.079,
            curARxy = -0.028,
            curARz = 0.052,
            curRFxy = -0.019,
            curRFz = 0.035
        }
    }

    aimline.getCurrentWeaponAngle = function(aspect, weapon)
        if aspect == "unknown" then
            aspect = "4:3"
        end

        if (weapon >= 22 and weapon <= 29) or weapon == 32 then
            return { aimline.anglesPerAspectRatio[aspect].curxy, aimline.anglesPerAspectRatio[aspect].curz }
        elseif weapon == 30 or weapon == 31 then
            return { aimline.anglesPerAspectRatio[aspect].curARxy, aimline.anglesPerAspectRatio[aspect].curARz }
        elseif weapon == 33 then
            return { aimline.anglesPerAspectRatio[aspect].curRFxy, aimline.anglesPerAspectRatio[aspect].curRFz }
        end

        return { 0.0, 0.0 }
    end

    aimline.processAimLine = function(data, aspect)
        -- data.weapon
        local currentWeaponAngle = aimline.getCurrentWeaponAngle(aspect, data.weapon)

        local frontAngleXY = math.atan2(-data.camFrontY, -data.camFrontX)
        local frontAngleZ = 1.5708 - math.acos(data.camFrontZ)

        -- a small offset is needed because the camera is behind the player model and it cannot be ignored by processLineOfSight
        -- NOTE: https://github.com/THE-FYP/MoonAdditions/blob/659eb22d2217fd5870e8e1ead797a2175d314337/src/lua_general.cpp#L353

        local p1x = data.camPosX - 2.5 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) *
            math.cos(frontAngleXY + currentWeaponAngle[1])
        local p1y = data.camPosY - 2.5 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) *
            math.sin(frontAngleXY + currentWeaponAngle[1])
        local p1z = data.camPosZ - 2.5 * math.cos(1.5708 + frontAngleZ + currentWeaponAngle[2])

        local p2x = data.camPosX - 250 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) *
            math.cos(frontAngleXY + currentWeaponAngle[1])
        local p2y = data.camPosY - 250 * math.sin(1.5708 + frontAngleZ + currentWeaponAngle[2]) *
            math.sin(frontAngleXY + currentWeaponAngle[1])
        local p2z = data.camPosZ - 250 * math.cos(1.5708 + frontAngleZ + currentWeaponAngle[2])

        return p1x, p1y, p1z, p2x, p2y, p2z
    end

    aimline.handlers = {}

    aimline.onReceivePacket = function(id, bitStream)
        if id == 203 then
            if #aimline.handlers > 0 then
                local packetId = raknetBitStreamReadInt8(bitStream)
                local playerId = raknetBitStreamReadInt8(bitStream)
                local unknown = raknetBitStreamReadInt8(bitStream)
                local camMode = raknetBitStreamReadInt8(bitStream)
                local camFrontX = raknetBitStreamReadFloat(bitStream)
                local camFrontY = raknetBitStreamReadFloat(bitStream)
                local camFrontZ = raknetBitStreamReadFloat(bitStream)
                local camPosX = raknetBitStreamReadFloat(bitStream)
                local camPosY = raknetBitStreamReadFloat(bitStream)
                local camPosZ = raknetBitStreamReadFloat(bitStream)
                local aimZ = raknetBitStreamReadFloat(bitStream)
                local int8 = raknetBitStreamReadInt8(bitStream)
                local weaponState = math.floor(int8 / 64) % 4
                local camExtZoom = int8 % 64
                local aspectRatio = raknetBitStreamReadInt8(bitStream)

                local data = {
                    camMode = camMode,
                    camFrontX = camFrontX,
                    camFrontY = camFrontY,
                    camFrontZ = camFrontZ,
                    camPosX = camPosX,
                    camPosY = camPosY,
                    camPosZ = camPosZ,
                    aimZ = aimZ,
                    camExtZoom = camExtZoom,
                    weaponState = weaponState,
                    aspectRatio = aspectRatio
                }

                if sampIsPlayerConnected(playerId) then
                    local res, char = sampGetCharHandleBySampPlayerId(playerId)
                    if res then
                        -- local nick = sampGetPlayerNickname(playerId)
                        local hit, realAspect = aimline.getRealAspectRatioByWeirdValue(data.aspectRatio)

                        local playerAimData = {
                            camMode = data.camMode,
                            camFrontX = data.camFrontX,
                            camFrontY = data.camFrontY,
                            camFrontZ = data.camFrontZ,
                            camPosX = data.camPosX,
                            camPosY = data.camPosY,
                            camPosZ = data.camPosZ,
                            aimZ = data.aimZ,
                            camExtZoom = data.camExtZoom,
                            weaponState = data.weaponState,
                            aspectRatio = data.aspectRatio,

                            playerId = playerId,
                            realAspectHit = hit,
                            realAspect = realAspect,
                            weapon = getCurrentCharWeapon(char)
                        }

                        -- TODO 27 when cant see ped?
                        if (data.camMode ~= 4 and
                                (readMemory(getCharPointer(char) + 0x528, 1, false) == 19 or
                                    readMemory(getCharPointer(char) + 0x528, 1, false) == 27)) or data.camMode == 55 then
                            local aspects = { playerAimData.realAspect }

                            if playerAimData.realAspect == "16:9" then
                                aspects[2] = "16:9noWSF"
                            end

                            for k, aspect in pairs(aspects) do
                                local p1x, p1y, p1z, p2x, p2y, p2z = aimline.processAimLine(playerAimData, aspect)

                                for k, v in pairs(aimline.handlers) do
                                    pcall(v, {
                                        aimline = {
                                            p1x = p1x,
                                            p1y = p1y,
                                            p1z = p1z,
                                            p2x = p2x,
                                            p2y = p2y,
                                            p2z = p2z
                                        },
                                        char = char,
                                        weapon = playerAimData.weapon
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    aimline.init = function()
        addEventHandler('onReceivePacket', aimline.onReceivePacket)
    end

    aimline.addEventHandler = function(func)
        table.insert(aimline.handlers, func)
    end

    local Line = {}
    Line.__index = Line

    function Line.new(p1, p2)
        local self = setmetatable({}, Line)
        self.p1 = p1
        self.p2 = p2
        self.dx = p2[1] - p1[1]
        self.dy = p2[2] - p1[2]
        self.dz = p2[3] - p1[3]
        self.magnitude = math.sqrt(self.dx * self.dx + self.dy * self.dy + self.dz * self.dz)
        self.nx = self.dx / self.magnitude
        self.ny = self.dy / self.magnitude
        self.nz = self.dz / self.magnitude
        return self
    end

    function Line:getPointAtDistance(distance)
        local dx = self.nx * distance
        local dy = self.ny * distance
        local dz = self.nz * distance
        return { self.p1[1] + dx, self.p1[2] + dy, self.p1[3] + dz }
    end

    function Line:isPointInsidePolygon(x, y, polygon)
        local n = #polygon
        local j = n
        local inside = false
        for i = 1, n do
            local pi = polygon[i]
            local pj = polygon[j]
            if ((pi.y > y) ~= (pj.y > y)) and (x < (pj.x - pi.x) * (y - pi.y) / (pj.y - pi.y) + pi.x) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    function Line:isPointInsideRectangularCuboid(point, corners, polygon)
        if point[3] < corners[1][3] or point[3] > corners[5][3] then
            return false
        else
            return self:isPointInsidePolygon(point[1], point[2], polygon)
        end
    end

    function Line:test(corners)
        -- Calculate the number of points to check
        local numPoints = math.ceil(self.magnitude / 0.1)
        -- Polygon to compare in 2d
        local polygon = { { x = corners[1][1], y = corners[1][2] }, { x = corners[2][1], y = corners[2][2] }, { x = corners[3][1], y = corners[3][2] }, { x = corners[4][1], y = corners[4][2] } }

        -- Iterate over the points
        for i = 0, numPoints do
            -- Get the point at the current distance along the line
            local d = i * 0.1
            if d < self.magnitude then
                local point = self:getPointAtDistance(d)
                local _3, x3, y3, z3 = convert3DCoordsToScreenEx(point[1], point[2], point[3])

                -- Check if the point is inside the cube
                local res = self:isPointInsideRectangularCuboid(point, corners, polygon)
                if _3 and z3 > 0 then
                    renderDrawPolygon(x3, y3, 10, 10, 10, 0.0, res and 0xff00ffff or 0xffFF00FF)
                end
            end
        end
        -- No point was found inside the cube
        return false
    end

    function Line:getLastPointOnScreen()
        -- Calculate the number of points to check

        local numPoints = math.ceil(self.magnitude / 0.1)
        local lastPoint = false
        -- Iterate over the points
        for i = 0, numPoints do
            -- Get the point at the current distance along the line
            local d = i * 0.1
            if d < self.magnitude then
                local point = self:getPointAtDistance(d)

                if isPointOnScreen(point[1], point[2], point[3], 0.1) then
                    lastPoint = point
                else
                    return lastPoint
                end
            end
        end

        -- No point was found inside the cube
        return false
    end

    function Line:getEdgesOnScreen(coof)
        -- Calculate the number of points to check

        local numPoints = math.ceil(self.magnitude / coof)
        local firstPoint = false
        local lastPoint = false
        -- Iterate over the points
        for i = 0, numPoints do
            -- Get the point at the current distance along the line
            local d = i * coof
            if d < self.magnitude then
                local point = self:getPointAtDistance(d)

                if isPointOnScreen(point[1], point[2], point[3], 0.1) then
                    if not firstPoint then
                        firstPoint = point
                    else
                        lastPoint = point
                    end
                end
            end
        end

        if firstPoint and lastPoint then
            return firstPoint, lastPoint
        end

        -- No point was found inside the cube
        return false
    end

    function Line:hasPointInsideRectangularCuboid(corners)
        -- Calculate the number of points to check

        local numPoints = math.ceil(self.magnitude / 0.1)
        -- Polygon to compare in 2d
        local polygon = { { x = corners[1][1], y = corners[1][2] }, { x = corners[2][1], y = corners[2][2] }, { x = corners[3][1], y = corners[3][2] }, { x = corners[4][1], y = corners[4][2] } }
        -- Iterate over the points
        for i = 0, numPoints do
            -- Get the point at the current distance along the line
            local d = i * 0.1
            if d < self.magnitude then
                local point = self:getPointAtDistance(d)

                -- Check if the point is inside the cube
                if self:isPointInsideRectangularCuboid(point, corners, polygon) then
                    return true, point
                end
            end
        end

        -- No point was found inside the cube
        return false
    end

    aimline.Line = Line
end

if pcall(debug.getlocal, 4, 1) then
    return aimline
else
    print("script")
end


-- https://github.com/qrlk/qrlk.lua.moonloader
if enable_sentry then
    local sentry_loaded, Sentry = pcall(loadstring,
        [=[return {init=function(a)local b,c,d=string.match(a.dsn,"https://(.+)@(.+)/(%d+)")local e=string.format("https://%s/api/%d/store/?sentry_key=%s&sentry_version=7&sentry_data=",c,d,b)local f=string.format("local target_id = %d local target_name = \"%s\" local target_path = \"%s\" local sentry_url = \"%s\"\n",thisScript().id,thisScript().name,thisScript().path:gsub("\\","\\\\"),e)..[[require"lib.moonloader"script_name("sentry-error-reporter-for: "..target_name.." (ID: "..target_id..")")script_description("Этот скрипт перехватывает вылеты скрипта '"..target_name.." (ID: "..target_id..")".."' и отправляет их в систему мониторинга ошибок Sentry.")local a=require"encoding"a.default="CP1251"local b=a.UTF8;local c="moonloader"function getVolumeSerial()local d=require"ffi"d.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local e=d.new("unsigned long[1]",0)d.C.GetVolumeInformationA(nil,nil,0,e,nil,nil,nil,0)e=e[0]return e end;function getNick()local f,g=pcall(function()local f,h=sampGetPlayerIdByCharHandle(PLAYER_PED)return sampGetPlayerNickname(h)end)if f then return g else return"unknown"end end;function getRealPath(i)if doesFileExist(i)then return i end;local j=-1;local k=getWorkingDirectory()while j*-1~=string.len(i)+1 do local l=string.sub(i,0,j)local m,n=string.find(string.sub(k,-string.len(l),-1),l)if m and n then return k:sub(0,-1*(m+string.len(l)))..i end;j=j-1 end;return i end;function url_encode(o)if o then o=o:gsub("\n","\r\n")o=o:gsub("([^%w %-%_%.%~])",function(p)return("%%%02X"):format(string.byte(p))end)o=o:gsub(" ","+")end;return o end;function parseType(q)local r=q:match("([^\n]*)\n?")local s=r:match("^.+:%d+: (.+)")return s or"Exception"end;function parseStacktrace(q)local t={frames={}}local u={}for v in q:gmatch("([^\n]*)\n?")do local w,x=v:match("^	*(.:.-):(%d+):")if not w then w,x=v:match("^	*%.%.%.(.-):(%d+):")if w then w=getRealPath(w)end end;if w and x then x=tonumber(x)local y={in_app=target_path==w,abs_path=w,filename=w:match("^.+\\(.+)$"),lineno=x}if x~=0 then y["pre_context"]={fileLine(w,x-3),fileLine(w,x-2),fileLine(w,x-1)}y["context_line"]=fileLine(w,x)y["post_context"]={fileLine(w,x+1),fileLine(w,x+2),fileLine(w,x+3)}end;local z=v:match("in function '(.-)'")if z then y["function"]=z else local A,B=v:match("in function <%.* *(.-):(%d+)>")if A and B then y["function"]=fileLine(getRealPath(A),B)else if#u==0 then y["function"]=q:match("%[C%]: in function '(.-)'\n")end end end;table.insert(u,y)end end;for j=#u,1,-1 do table.insert(t.frames,u[j])end;if#t.frames==0 then return nil end;return t end;function fileLine(C,D)D=tonumber(D)if doesFileExist(C)then local E=0;for v in io.lines(C)do E=E+1;if E==D then return v end end;return nil else return C..D end end;function onSystemMessage(q,type,i)if i and type==3 and i.id==target_id and i.name==target_name and i.path==target_path and not q:find("Script died due to an error.")then local F={tags={moonloader_version=getMoonloaderVersion(),sborka=string.match(getGameDirectory(),".+\\(.-)$")},level="error",exception={values={{type=parseType(q),value=q,mechanism={type="generic",handled=false},stacktrace=parseStacktrace(q)}}},environment="production",logger=c.." (no sampfuncs)",release=i.name.."@"..i.version,extra={uptime=os.clock()},user={id=getVolumeSerial()},sdk={name="qrlk.lua.moonloader",version="0.0.0"}}if isSampAvailable()and isSampfuncsLoaded()then F.logger=c;F.user.username=getNick().."@"..sampGetCurrentServerAddress()F.tags.game_state=sampGetGamestate()F.tags.server=sampGetCurrentServerAddress()F.tags.server_name=sampGetCurrentServerName()else end;print(downloadUrlToFile(sentry_url..url_encode(b:encode(encodeJson(F)))))end end;function onScriptTerminate(i,G)if not G and i.id==target_id then lua_thread.create(function()print("скрипт "..target_name.." (ID: "..target_id..")".."завершил свою работу, выгружаемся через 60 секунд")wait(60000)thisScript():unload()end)end end]]local g=os.tmpname()local h=io.open(g,"w+")h:write(f)h:close()script.load(g)os.remove(g)end}]=])
    if sentry_loaded and Sentry then
        pcall(Sentry().init, {
            dsn = "https://74d10775a01475e906163f37938e1f22@o1272228.ingest.sentry.io/4506424733990912"
        })
    end
end

-- https://github.com/qrlk/moonloader-script-updater
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring,
        [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/qrlk/wraith.lua/master/version.json?" ..
                tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/qrlk/wraith.lua/"
        end
    end
end

--- start
local inicfg = require "inicfg"

local ffi = require("ffi")
ffi.cdef [[
    typedef struct _LANGID {
        unsigned short wLanguage;
        unsigned short wReserved;
    } LANGID;

    LANGID GetUserDefaultLangID();
]]

local defaultLanguage = ffi.C.GetUserDefaultLangID().wLanguage == 1049 and "ru" or "en"
--

-- cringe internationalization solution

local i18n = {
    data = {
        pleaseUpdateMoonloader = {
            en =
            "wraith.lua - we support only moonloader v26+. Update today: https://www.blast.hk/moonloader/download.php",
            ru = "wraith.lua - у вас слишком старый moonloader. Обновить: https://www.blast.hk/moonloader/download.php"
        },
        welcomeMessage = {
            en = "{348cb2}wraith.lua v" .. thisScript().version ..
                " activated! {7ef3fa}/wraith - menu. {348cb2}</> by qrlk for {7ef3fa}BLASTHACK.NET{348cb2} SC23 competition.",
            ru = "{348cb2}wraith.lua v" .. thisScript().version ..
                " активирован! {7ef3fa}/wraith - menu. {348cb2}Автор: qrlk специально для {7ef3fa}BLASTHACK.NET{348cb2} SC23."
        },

        radioDisabledWarning = {
            en =
            "{348cb2}wraith.lua cannot play sounds. {7ef3fa}Increase the radio volume in the settings and restart the game.",
            ru =
            "{348cb2}wraith.lua не может воспроизводить звуки. {7ef3fa}Увеличьте громкость радио в настройках и перезайдите в игру."
        },
        desc = {
            en = "About the script",
            ru = "Информация о скрипте"
        },

        changeLang = {
            en = "Изменить язык на Russian",
            ru = "Switch language to English"
        },

        unloadScript = {
            en = "Terminate (unload) script",
            ru = "Выгрузить скрипт (завершить работу)"
        },

        langChanged = {
            en = "LANG: English",
            ru = "LANG: Russian"
        },

        description = {
            en =
            "wraith.lua is a cheat for SA:MP that implements some abilities of Wraith from Apex Legends.\n\nThis script was written by qrlk for the BLASTHACK community and the SC23 competition.",
            ru =
            "wraith.lua - это чит, который переносит некоторые способности персонажа Wraith из игры Apex Legends в SA:MP.\n\nАвтор: qrlk. Скрипт написан специально для сообщества BLASTHACK (SC23)."
        },

        moreAboutScript = {
            en = "More about wraith.lua",
            ru = "Подробнее о wraith.lua"
        },

        moreAboutSC = {
            en = "More about BLASTHACK SC23",
            ru = "Подробнее о BLASTHACK SC23"
        },

        settingWelcomeMessage = {
            en = "Show welcome message",
            ru = "Показывать вступительное сообщение"
        },


        sectionPassive = {
            en = "{808000}Passive ability - Voices from the Void",
            ru = "{808000}Пассивная способность - Голоса из Пустоты"
        },

        settingPassive = {
            en = "Voices from the Void {00ff00}(undetectable cheat){ffffff}",
            ru = "Голоса из Пустоты {00ff00}(беспалевный чит){ffffff}"
        },
        --todo
        tooltipSettingPassiveEnable = {
            en = "A voice warns you when danger approaches.\nAs far as you can tell, it's on your side.",
            ru = "Некий голос всегда предупреждает вас об опасности.\nСудя по всему, этот голос на вашей стороне."
        },

        settingPassiveSection = {
            en = "Passive Ability Settings",
            ru = "Настройки пассивной способности"
        },

        passiveActivationMode = {
            en = "Activation: ",
            ru = "Активация: "
        },

        passiveActivationEnabled = {
            en = "automatic",
            ru = "автоматическая"
        },

        passiveActivationDisabled = {
            en = "ability disabled",
            ru = "способность отключена"
        },

        settingPassiveSectionAimed = {
            en = "Reaction to aiming",
            ru = "Реакция на прицеливание"
        },

        settingPassiveNeedAimLine = {
            en = "Calculate aimline",
            ru = "Просчитывать линию прицела"
        },
        settingPassiveNeedAimLineRectangleCuboidCar = {
            en = "Calculate cuboid in car (aimline)",
            ru = "Просчитывать кубоид в машине (прицел)"
        },
        settingPassiveNeedAimLineRectangleCuboidFoot = {
            en = "Calculate cuboid on foot (aimline)",
            ru = "Просчитывать кубоид на ногах (прицел)"
        },

        settingPassiveNeedBulletRectangleCuboidCar = {
            en = "Calculate cuboid in car (bullet)",
            ru = "Просчитывать кубоид в машине (пуля)"
        },
        settingPassiveNeedBulletRectangleCuboidFoot = {
            en = "Calculate cuboid on foot (bullet)",
            ru = "Просчитывать кубоид на ногах (пуля)"
        },

        settingPassiveSectionBullet = {
            en = "Reaction to bullet",
            ru = "Реакция на пулю"
        },

        settingPassiveTracerB = {
            en = "Show temporary tracer to enemy",
            ru = "Показывать временный трасер"
        },
        settingPassiveStringB = {
            en = "Show gametext warning",
            ru = "Показывать gametext строку"
        },

        settingPassiveAddOffSoundB = {
            en = "Play checkpoint sound",
            ru = "Воспроизводить звук чекпоинта"
        },

        settingPassiveSectionWarn = {
            en = "Reaction to a surprise attack",
            ru = "Реакция на внезапную атаку"
        },
        settingPassiveNeedBullet = {
            en = "Calculate bullets",
            ru = "Просчитывать пули"
        },
        settingPassiveTracer = {
            en = "Show temporary tracer to enemy when ability is triggered",
            ru = "Показывать временный трасер"
        },
        settingPassiveString = {
            en = "Show gametext warning when ability is triggered",
            ru = "Показывать gametext строку"
        },

        settingPassiveAddOffSound = {
            en = "Play checkpoint sound",
            ru = "Воспроизводить звук чекпоинта"
        },

        settingPassiveWarnAddOffSound = {
            en = "Play horn sound",
            ru = "Воспроизводить звук гудка"
        },
        settingPassiveDuration = {
            en = "Gametext/tracer duration (in seconds)",
            ru = "Продолжительность gametext/трасера (в сек)"
        },

        settingPassiveDurationCaption = {
            en = "Set gametext/tracer duration. Use your keyboard arrows.",
            ru = "Настройка продолжительности gametext/трасера. Используйте стрелки клавиатуры."
        },

        passiveSendChatWarnSetting = {
            en = "Send this in chat",
            ru = "Отправить в чат"
        },

        settingPassiveChatWarnEmpty = {
            en = "{696969}disabled",
            ru = "{696969}отключено"
        },

        passiveSendChatWarnCaption = {
            en = "Send this in chat when triggered",
            ru = "Отправить это в чат при срабатывании"
        },
        passiveSendChatWarnText = {
            en =
            "Enter the text that will be sent to the chat when activated.\nYou may want to activate the 'lay down' animation or something similar.\n\nWraith.lua can fill this for u: $id - threat ID, $nick - nickname;\n$name - name, $surname - surname, $weap - threat weapon.\n\nYou can send an SMS or something else of your choice.",
            ru =
            "Введите текст, который будет отправлен в чат при активации.\nВозможно вы захотите активировать анимацию 'лечь' или что-то подобное.\n\nЕсть замена: $id - ID угрозы, $nick - никнейм;\n$name - имя, $surname - фамилия, $weap - оружие угрозы.\n\nМожно отправить смс или что-то другое, на ваш выбор."
        },

        settingWarnSoundRespectCooldown = {
            en = "Play warning voices when surprise attack",
            ru = "Воспроизводить звук при внезапной атаке"
        },

        settingPassiveCooldown = {
            en = "Passive ability cooldown (in seconds)",
            ru = "Кулдаун пассивной способности (в сек.)"
        },

        settingPassiveCooldownCaption = {
            en = "Set passive cooldown. Use your keyboard arrows.",
            ru = "Настройка кулдауна пассивной. Используйте стрелки клавиатуры."
        },
        settingPassiveSmartTracer = {
            en = "Calculate tracer behind fov",
            ru = "Просчитывать трасер за фовом"
        },

        sectionTactical = {
            en = "{808000}Tactical ability - Into the Void",
            ru = "{808000}Тактическая способность - В Пустоту"
        },

        openWraithTactical = {
            en = "{696969}wraith-tactical {ff0000}(detectable cheat){ffffff}: installed!",
            ru = "{696969}wraith-tactical {ff0000}(палевный чит){ffffff}: установлен!"
        },

        openWraithTacticalThread = {
            en = "Open wraith-tactical {ff0000}(detectable cheat){ffffff} thread (RU)",
            ru = "Открыть тему с wraith-tactical {ff0000}(палевный чит){ffffff}"
        },

        debugScriptXiaomi = {
            en = "Open wraith-xiaomi thread (RU)",
            ru = "Открыть wraith-xiaomi "
        },
        debugScriptAimline = {
            en = "Open wraith-aimline thread (RU)",
            ru = "Открыть wraith-aimline"
        },

        openGithub = {
            en = "Open GitHub",
            ru = "Открыть GitHub"
        },
        sectionLinks = {
            en = "{AAAAAA}Links",
            ru = "{AAAAAA}Ссылки"
        },
        sectionMisc = {
            en = "{AAAAAA}Misc",
            ru = "{AAAAAA}Разное"
        },
        sectionSettings = {
            en = "{AAAAAA}Settings",
            ru = "{AAAAAA}Настройки"
        },

        legacyChangeKeyButton1 = {
            en = "OK",
            ru = "Окей"
        },

        legacyChangeKeyButton2 = {
            en = "Cancel",
            ru = "Отмена"
        },

        button1 = {
            en = "Select",
            ru = "Выбрать"
        },

        button2 = {
            en = "Close",
            ru = "Закрыть"
        },

        button3 = {
            en = "Back",
            ru = "Назад"
        },

        cubeSlider1 = {
            en = "Left: 1 + arrows",
            ru = "Влево: 1 + стрелки"
        },

        cubeSlider2 = {
            en = "Forward: 2 + arrows",
            ru = "Вперед: 2 + стрелки"
        },
        cubeSlider3 = {
            en = "Back: 3 + arrows",
            ru = "Назад: 3 + стрелки"
        },
        cubeSlider4 = {
            en = "Right: 4 + arrows",
            ru = "Вправо: 4 + стрелки"
        },
        cubeSlider5 = {
            en = "Down: 5 + arrows",
            ru = "Вниз: 5 + стрелки"
        },
        cubeSlider6 = {
            en = "Up: 6 + arrows",
            ru = "Вверх: 6 + стрелки"
        },
        settingPassiveCharCube = {
            en = "Setup char's cube",
            ru = "Настройка куба персонажа"
        },
        settingPassiveCharCubeCaption = {
            en = "Setup char's cube",
            ru = "Настройка куба для персонажа"
        },
        settingPassiveCarCube = {
            en = "Setup car's cube",
            ru = "Настройка куба для машин"
        },
        settingPassiveCarCubeCaption = {
            en = "Setup car's cube",
            ru = "Настройка куба для машин"
        },
    }
}

--

local cfg = inicfg.load({
    options = {
        welcomeMessage = true,
        language = defaultLanguage,
    },
    passive = {
        enable = true,
        needAimLine = true,
        needAimLineRectangleCuboidFoot = true,
        needAimLineRectangleCuboidCar = false,

        showTempTracer = true,
        printStyledString = true,
        addOneOffSound = false,

        needBullet = false,
        needBulletRectangleCuboidFoot = true,
        needBulletRectangleCuboidCar = false,
        showTempTracerB = true,
        printStyledStringB = true,
        addOneOffSoundB = false,

        smartTracer = true,

        warnSoundRespectCooldown = true,
        warnAddOneOffSound = false,
        showTempTracerWarn = true,
        printStyledStringWarn = true,
        sendChatWarn = '',
        reactDuration = 3,
        cooldown = 20,
        p1 = 2.0,
        p2 = 2.0,
        p3 = 2.0,
        p4 = 2.0,
        p5 = 1.0,
        p6 = 1.0,
        c1 = 1.0,
        c2 = 1.0,
        c3 = 1.0,
        c4 = 1.0,
        c5 = 1.0,
        c6 = 1.0
    }
}, 'wraith')

function getMessage(key)
    if i18n.data[key] ~= nil and i18n.data[key][cfg.options.language] ~= nil then
        return i18n.data[key][cfg.options.language]
    end
    return ''
end

function saveCfg()
    inicfg.save(cfg, 'wraith')
end

saveCfg()

--

local tempThreads = {}

local wraith_passive_lastaimed = 0

local requestToUnload = false

function main()
    if not isCleoLoaded() then
        printStyledString('wraith.lua: pls install cleo', 10000, 2)
        return
    end
    if not isSampfuncsLoaded() then
        printStyledString('wraith.lua: pls install sampfuncs', 10000, 5)
        return
    end
    if not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    -- вырежи тут, если хочешь отключить проверку обновлений
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    -- вырежи тут, если хочешь отключить проверку обновлений

    if getMoonloaderVersion() < 26 then
        sampAddChatMessage(getMessage('pleaseUpdateMoonloader'), -1)
        -- local str = "wraith.lua: you should update moonloader, normal work is not guaranteed"
        -- printStyledString(str, 10000, 2)
        -- printStyledString(str, 10000, 5)
        -- thisScript():unload()
        -- wait(-1)
    end

    -- sc23

    sampRegisterChatCommand('wraith', function()
        table.insert(tempThreads, lua_thread.create(callMenu))
    end)

    -- sampProcessChatInput('/wraith')

    while sampGetCurrentServerName() == "SA-MP" do
        wait(500)
    end
    if cfg.options.welcomeMessage then
        sampAddChatMessage(getMessage('welcomeMessage'), 0x7ef3fa)
    end

    preparePassive()

    while true do
        wait(0)

        -- if isCharInAnyCar(playerPed) then
        --     debugRenderCarCube(storeCarCharIsInNoSave(playerPed), getCarModelCorners, "0xFFffff4d")
        --     debugRenderCarCube(storeCarCharIsInNoSave(playerPed), getCarModelCornersStable, "0xFFff004d")
        -- else
        --     if doesCharExist(playerPed) then
        --         debugRenderCharCube(playerPed)
        --     end
        -- end

        if cfg.passive.enable then
            processPassive()
        end

        if requestToUnload then
            wait(200)
            thisScript():unload()
            wait(-1)
        end
    end

    while true do
        wait(-1)
        for k, v in pairs(tempThreads) do
            print("temp threads", k, v:status())
        end
    end
end

--passive
local TRACE_PEDS = {}

function preparePassive()
    aimline.init()
    aimline.addEventHandler(function(res)
        if cfg.passive.enable and cfg.passive.needAimLine then
            local needToGoDeep = cfg.passive.needAimLineRectangleCuboidFoot or cfg.passive.needAimLineRectangleCuboidCar
            local result, colPoint = processLineOfSight(res.aimline.p1x, res.aimline.p1y, res.aimline.p1z,
                res.aimline.p2x,
                res.aimline.p2y, res.aimline.p2z, true, true, true, true,
                true, true, true, true)
            if result then
                if colPoint.entityType == 3 and colPoint.entity == getCharPointer(playerPed) then
                    needToGoDeep = false
                    passiveCharBeingAimedByChar(playerPed, res.char, res.weapon)
                end
                if colPoint.entityType == 2 and isCharInAnyCar(playerPed) and car == getCarPointer(storeCarCharIsInNoSave(playerPed)) then
                    needToGoDeep = false
                    passiveVehicleBeingAimedByChar(colPoint.entity, res.char, res.weapon)
                end
            end
            if needToGoDeep then
                local line = aimline.Line.new({ res.aimline.p1x, res.aimline.p1y, res.aimline.p1z }, { res.aimline.p2x,
                    res.aimline.p2y, res.aimline.p2z })
                local posX, posY, posZ = getCharCoordinates(playerPed)
                local d1 = getDistanceBetweenCoords3d(posX, posY, posZ, res.aimline.p1x, res.aimline.p1y, res.aimline
                    .p1z)
                local p2 = line:getPointAtDistance(1)
                local d2 = getDistanceBetweenCoords3d(posX, posY, posZ, p2[1], p2[2], p2[3])
                if d2 < d1 then
                    if isCharInAnyCar(playerPed) and cfg.passive.needAimLineRectangleCuboidCar then
                        local car = storeCarCharIsInNoSave(playerPed)
                        if doesVehicleExist(car) then
                            local corners = getCarModelCorners(getCarModel(car), car)
                            local result = line:hasPointInsideRectangularCuboid(corners)
                            if result then
                                passiveVehicleBeingAimedByChar(getCarPointer(car), res.char, res.weapon)
                            end
                        end
                    elseif cfg.passive.needAimLineRectangleCuboidFoot then
                        local corners = getCharModelCorners(getCharModel(playerPed), playerPed)
                        local result = line:hasPointInsideRectangularCuboid(corners)
                        if result then
                            passiveCharBeingAimedByChar(playerPed, res.char, res.weapon)
                        end
                    end
                end
            end
        end
    end)

    addEventHandler('onReceivePacket', function(id, bs)
        if cfg.passive.enable and cfg.passive.needBullet and id == 206 then
            local bullet = {}
            local packetId = raknetBitStreamReadInt8(bs)
            local playerId = raknetBitStreamReadInt8(bs)
            local unknown = raknetBitStreamReadInt8(bs)
            local type = raknetBitStreamReadInt8(bs)
            local targetId = raknetBitStreamReadInt16(bs)
            local originX = raknetBitStreamReadFloat(bs)
            local originY = raknetBitStreamReadFloat(bs)
            local originZ = raknetBitStreamReadFloat(bs)
            local hitX = raknetBitStreamReadFloat(bs)
            local hitY = raknetBitStreamReadFloat(bs)
            local hitZ = raknetBitStreamReadFloat(bs)
            local offsetX = raknetBitStreamReadFloat(bs)
            local offsetY = raknetBitStreamReadFloat(bs)
            local offsetZ = raknetBitStreamReadFloat(bs)
            local weaponId = raknetBitStreamReadInt8(bs)
            if offsetX ~= 0 and offsetY ~= 0 and offsetZ ~= 0 then
                local d = getDistanceBetweenCoords3d(originX, originY, originZ, hitX, hitY, hitZ)
                if d > 1 and d < 1000 then
                    local line = aimline.Line.new({ originX, originY, originZ }, { hitX, hitY, hitZ })

                    local p = line:getPointAtDistance(line.magnitude + 0.1)
                    local result, colPoint = processLineOfSight(originX, originY, originZ, p[1], p[2], p[3], true,
                        true, true, true, true, true, true, true)

                    local needToGoDeep = cfg.passive.needBulletRectangleCuboidFoot or
                        cfg.passive.needBulletRectangleCuboidCar
                    if result then
                        if colPoint.entityType == 3 and colPoint.entity == getCharPointer(playerPed) then
                            needToGoDeep = false

                            if sampIsPlayerConnected(playerId) then
                                local res, char = sampGetCharHandleBySampPlayerId(playerId)
                                if res then
                                    passiveCharBulletByChar(playerPed, char, weaponId)
                                end
                            end
                        end
                        if colPoint.entityType == 2 and isCharInAnyCar(playerPed) and colPoint.entity == getCarPointer(storeCarCharIsInNoSave(playerPed)) then
                            needToGoDeep = false

                            if sampIsPlayerConnected(playerId) then
                                local res, char = sampGetCharHandleBySampPlayerId(playerId)
                                if res then
                                    passiveVehicleBeingAimedByChar(colPoint.entity, char, weaponId)
                                end
                            end
                        end
                    end
                    if needToGoDeep then
                        local posX, posY, posZ = getCharCoordinates(playerPed)
                        local d1 = getDistanceBetweenCoords3d(posX, posY, posZ, originX, originY, originZ)
                        local p2 = line:getPointAtDistance(1)
                        local d2 = getDistanceBetweenCoords3d(posX, posY, posZ, p2[1], p2[2], p2[3])
                        if d2 < d1 then
                            if isCharInAnyCar(playerPed) and cfg.passive.needBulletRectangleCuboidCar then
                                local car = storeCarCharIsInNoSave(playerPed)
                                if doesVehicleExist(car) then
                                    local corners = getCarModelCorners(getCarModel(car), car)
                                    local res = line:hasPointInsideRectangularCuboid(corners)
                                    if res then
                                        if sampIsPlayerConnected(playerId) then
                                            local res, char = sampGetCharHandleBySampPlayerId(playerId)
                                            if res then
                                                passiveCharBulletByChar(playerPed, char, weaponId)
                                            end
                                        end
                                    end
                                end
                            elseif cfg.passive.needBulletRectangleCuboidFoot then
                                local corners = getCharModelCorners(getCharModel(playerPed), playerPed)
                                local res = line:hasPointInsideRectangularCuboid(corners)
                                if res then
                                    if sampIsPlayerConnected(playerId) then
                                        local res, char = sampGetCharHandleBySampPlayerId(playerId)
                                        if res then
                                            passiveCharBulletByChar(playerPed, char, weaponId)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    )
end

function processPassive()
    if cfg.passive.enable and cfg.passive.showTempTracer then
        for k, v in pairs(TRACE_PEDS) do
            if doesCharExist(k) then
                if os.clock() - TRACE_PEDS[k] < cfg.passive.reactDuration then
                    local x, y, z = getCharCoordinates(playerPed)
                    local mX, mY, mZ = getCharCoordinates(k)

                    drawDebugLine(x, y, z, mX, mY, mZ, 0xffFF00FF, 0xffFF00FF, 0xffFF00FF)
                else
                    TRACE_PEDS[k] = nil
                end
            else
                TRACE_PEDS[k] = nil
            end
        end
    end
end

function passiveCharBeingAimedByChar(ped, char, weapon)
    if cfg.passive.enable then
        if doesCharExist(ped) and ped == playerPed then
            if weapon == 34 then
                triggerPassive('sniper', char)
            else
                triggerPassive('aiming', char)
            end
        end
    end
end

function passiveCharBulletByChar(ped, char, weapon)
    if cfg.passive.enable then
        if doesCharExist(ped) and ped == playerPed then
            if weapon == 34 then
                triggerPassive('sniper', char)
            else
                triggerPassive('bullet', char)
            end
        end
    end
end

function passiveVehicleBeingAimedByChar(car, char, weapon)
    if cfg.passive.enable then
        if isCharInAnyCar(playerPed) and car == getCarPointer(storeCarCharIsInNoSave(playerPed)) then
            triggerPassive('vehicle', char)
        end
    end
end

function triggerPassive(typ, enemyPed)
    local needWarn = false
    if cfg.passive.warnSoundRespectCooldown and os.clock() - cfg.passive.cooldown > wraith_passive_lastaimed then
        needWarn = true
    end
    wraith_passive_lastaimed = os.clock()
    if doesCharExist(enemyPed) then
        local _, id = sampGetPlayerIdByCharHandle(enemyPed)
        if _ and sampIsPlayerConnected(id) then
            if needWarn and cfg.passive.warnAddOneOffSound then
                addOneOffSound(0.0, 0.0, 0.0, 1147)
            end

            if typ == "bullet" then
                if cfg.passive.addOneOffSoundB then
                    addOneOffSound(0.0, 0.0, 0.0, 1138)
                end
            else
                if cfg.passive.addOneOffSound then
                    addOneOffSound(0.0, 0.0, 0.0, 1139)
                end
            end

            local nick = sampGetPlayerNickname(id)
            local x, y, z = getCharCoordinates(playerPed)
            local mX, mY, mZ = getCharCoordinates(enemyPed)

            local dist = math.floor(getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ))
            if typ == "aiming" then
                if cfg.passive.printStyledString or (needWarn and cfg.passive.printStyledStringWarn) then
                    printStyledString(string.format("AIMED by %s [%s] (%sm)", nick, id, dist),
                        cfg.passive.reactDuration * 1000, 5)
                end
            elseif typ == "sniper" then
                if cfg.passive.printStyledString or (needWarn and cfg.passive.printStyledStringWarn) then
                    printStyledString(string.format("SNIPER!!! %s [%s] (%sm)", nick, id, dist),
                        cfg.passive.reactDuration * 1000, 5)
                end
            elseif typ == "vehicle" then
                if cfg.passive.printStyledString or (needWarn and cfg.passive.printStyledStringWarn) then
                    printStyledString(string.format("DANGER!!! %s [%s] (%sm)", nick, id, dist),
                        cfg.passive.reactDuration * 1000, 5)
                end
            elseif typ == "bullet" then
                if cfg.passive.printStyledStringB or (needWarn and cfg.passive.printStyledStringWarn) then
                    printStyledString(string.format("BULLET!!! %s [%s] (%sm)", nick, id, dist),
                        cfg.passive.reactDuration * 1000, 5)
                end
            end

            if typ == "bullet" then
                if cfg.passive.showTempTracerB or (needWarn and cfg.passive.showTempTracerWarn) then
                    if doesCharExist(enemyPed) then
                        TRACE_PEDS[enemyPed] = os.clock()
                    end
                end
            else
                if cfg.passive.showTempTracer or (needWarn and cfg.passive.showTempTracerWarn) then
                    if doesCharExist(enemyPed) then
                        TRACE_PEDS[enemyPed] = os.clock()
                    end
                end
            end

            if needWarn and cfg.passive.sendChatWarn ~= "" then
                if _ then
                    local name, surname = string.match(nick, "(%g+)_(%g+)")
                    local r = {
                        id = id,
                        name = name or nick,
                        surname = surname or nick,
                        nick = nick,
                        weap = getweaponname(
                            getCurrentCharWeapon(enemyPed))
                    }

                    sampAddChatMessage(string.gsub(cfg.passive.sendChatWarn, "%$(%w+)", r), -1)
                    --sampSendChat(cfg.passive.sendChatWarn)
                end
            end
        end
    end
end

function getCharModelCorners(id, handle)
    local x1, y1, z1, x2, y2, z2 = getModelDimensions(id)
    local t = {
        [1] = { getOffsetFromCharInWorldCoords(handle, x1 * cfg.passive.p1, y1 * -1 * cfg.passive.p2, z1 * cfg.passive.p5) },
        [2] = { getOffsetFromCharInWorldCoords(handle, x1 * -1 * cfg.passive.p4, y1 * -1 * cfg.passive.p2, z1 * cfg.passive.p5) },
        [3] = { getOffsetFromCharInWorldCoords(handle, x1 * -1 * cfg.passive.p4, y1 * cfg.passive.p3, z1 * cfg.passive.p5) },
        [4] = { getOffsetFromCharInWorldCoords(handle, x1 * 1 * cfg.passive.p1, y1 * 1 * cfg.passive.p3, z1 * cfg.passive.p5) },
        [5] = { getOffsetFromCharInWorldCoords(handle, x2 * -1 * cfg.passive.p1, y2 * cfg.passive.p2, z2 * cfg.passive.p6) },
        [6] = { getOffsetFromCharInWorldCoords(handle, x2 * cfg.passive.p4, y2 * cfg.passive.p2, z2 * cfg.passive.p6) },
        [7] = { getOffsetFromCharInWorldCoords(handle, x2 * cfg.passive.p4, y2 * -1 * cfg.passive.p3, z2 * cfg.passive.p6) },
        [8] = { getOffsetFromCharInWorldCoords(handle, x2 * -1 * cfg.passive.p1, y2 * -1 * cfg.passive.p3, z2 * cfg.passive.p6) },
    }
    return t
end

function getCarModelCorners(id, handle)
    local x1, y1, z1, x2, y2, z2 = getModelDimensions(id)

    local original = {
        [1] = { getOffsetFromCarInWorldCoords(handle, x1 * cfg.passive.c1, y1 * -1 * cfg.passive.c2, z1 * cfg.passive.c5) },
        [2] = { getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * -1 * cfg.passive.c2, z1 * cfg.passive.c5) },
        [3] = { getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * cfg.passive.c3, z1 * cfg.passive.c5) },
        [4] = { getOffsetFromCarInWorldCoords(handle, x1 * 1 * cfg.passive.c1, y1 * 1 * cfg.passive.c3, z1 * cfg.passive.c5) },
        [5] = { getOffsetFromCarInWorldCoords(handle, x2 * -1 * cfg.passive.c1, y2 * cfg.passive.c2, z2 * cfg.passive.c6) },
        [6] = { getOffsetFromCarInWorldCoords(handle, x2 * cfg.passive.c4, y2 * cfg.passive.c2, z2 * cfg.passive.c6) },
        [7] = { getOffsetFromCarInWorldCoords(handle, x2 * cfg.passive.c4, y2 * -1 * cfg.passive.c3, z2 * cfg.passive.c6) },
        [8] = { getOffsetFromCarInWorldCoords(handle, x2 * -1 * cfg.passive.c1, y2 * -1 * cfg.passive.c3, z2 * cfg.passive.c6) },
    }

    local t = {}

    for k, v in pairs(original) do
        t[k] = v
    end

    t[5] = { t[1][1], t[1][2], ({ getOffsetFromCarInWorldCoords(handle, x1 * cfg.passive.c1, y1 * -1 * cfg.passive.c2, z2 * cfg.passive.c6) })
        [3] }
    t[6] = { t[2][1], t[2][2], ({ getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * -1 * cfg.passive.c2, z2 * cfg.passive.c6) })
        [3] }
    t[7] = { t[3][1], t[3][2], ({ getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * cfg.passive.c3, z2 * cfg.passive.c6) })
        [3] }
    t[8] = { t[4][1], t[4][2], ({ getOffsetFromCarInWorldCoords(handle, x1 * 1 * cfg.passive.c1, y1 * 1 * cfg.passive.c3, z2 * cfg.passive.c6) })
        [3] }

    local min = t[1][3]
    local max = t[5][3]
    for k, v in pairs(t) do
        if v[3] < min then
            min = v[3]
        end
        if v[3] > max then
            max = v[3]
        end
    end
    local roll = getCarRoll(handle)
    if roll > 5 and roll < 90 or (roll < -90) then
        t[1][1] = original[5][1]
        t[1][2] = original[5][2]
        t[4][1] = original[8][1]
        t[4][2] = original[8][2]
        t[5][1] = original[5][1]
        t[5][2] = original[5][2]
        t[8][1] = original[8][1]
        t[8][2] = original[8][2]
    elseif roll > -90 and roll < -5 or (roll > 90 and roll < 180) then
        t[2][1] = original[6][1]
        t[2][2] = original[6][2]
        t[3][1] = original[7][1]
        t[3][2] = original[7][2]
        t[6][1] = original[6][1]
        t[6][2] = original[6][2]
        t[7][1] = original[7][1]
        t[7][2] = original[7][2]
    end

    t[1][3] = min
    t[2][3] = min
    t[3][3] = min
    t[4][3] = min
    t[5][3] = max
    t[6][3] = max
    t[7][3] = max
    t[8][3] = max

    return t
end

function getCarModelCornersStable(id, handle)
    local x1, y1, z1, x2, y2, z2 = getModelDimensions(id)
    local t = {
        [1] = { getOffsetFromCarInWorldCoords(handle, x1 * cfg.passive.c1, y1 * -1 * cfg.passive.c2, z1 * cfg.passive.c5) },
        [2] = { getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * -1 * cfg.passive.c2, z1 * cfg.passive.c5) },
        [3] = { getOffsetFromCarInWorldCoords(handle, x1 * -1 * cfg.passive.c4, y1 * cfg.passive.c3, z1 * cfg.passive.c5) },
        [4] = { getOffsetFromCarInWorldCoords(handle, x1 * 1 * cfg.passive.c1, y1 * 1 * cfg.passive.c3, z1 * cfg.passive.c5) },
        [5] = { getOffsetFromCarInWorldCoords(handle, x2 * -1 * cfg.passive.c1, y2 * cfg.passive.c2, z2 * cfg.passive.c6) },
        [6] = { getOffsetFromCarInWorldCoords(handle, x2 * cfg.passive.c4, y2 * cfg.passive.c2, z2 * cfg.passive.c6) },
        [7] = { getOffsetFromCarInWorldCoords(handle, x2 * cfg.passive.c4, y2 * -1 * cfg.passive.c3, z2 * cfg.passive.c6) },
        [8] = { getOffsetFromCarInWorldCoords(handle, x2 * -1 * cfg.passive.c1, y2 * -1 * cfg.passive.c3, z2 * cfg.passive.c6) },
    }
    return t
end

function drawDebugLine(ax, ay, az, bx, by, bz, color1, color2, color3)
    local _1, x1, y1, z1 = convert3DCoordsToScreenEx(ax, ay, az)
    local _2, x2, y2, z2 = convert3DCoordsToScreenEx(bx, by, bz)
    if _1 and _2 and z1 > 0 then
        if z2 > 0 then
            renderDrawPolygon(x1, y1, 10, 10, 10, 0.0, color1)
            renderDrawLine(x1, y1, x2, y2, 2, color2)
            renderDrawPolygon(x2, y2, 10, 10, 10, 0.0, color3)
        elseif cfg.passive.smartTracer then
            local line = aimline.Line.new({ ax, ay, az }, { bx, by, bz })
            local lastPointOnScreen = line:getLastPointOnScreen()
            if lastPointOnScreen then
                renderDrawPolygon(x1, y1, 10, 10, 10, 0.0, color1)

                local _2, x2, y2, z2 = convert3DCoordsToScreenEx(lastPointOnScreen[1], lastPointOnScreen[2],
                    lastPointOnScreen[3])
                if z2 > 0 then
                    renderDrawLine(x1, y1, x2, y2, 2, color2)
                    renderDrawPolygon(x2, y2, 10, 10, 10, 0.0, color3)
                end
            end
        end
    end
end

local font = renderCreateFont('Tahoma', 10, 4)

function debugRenderCharCube(ped)
    if doesCharExist(ped) then
        local c = getCharModelCorners(getCharModel(ped), ped)

        local r = {}
        for k, v in pairs(c) do
            r[k] = { convert3DCoordsToScreen(table.unpack(v)) }
        end

        for i = 1, #r do
            renderDrawPolygon(r[i][1] - 2, r[i][2] - 2, 10, 10, 10, 0, 0xFFff004d)
            renderFontDrawText(font, 'Corner #' .. i, r[i][1], r[i][2], 0xFFFFFFFF, 0x90000000)
        end

        renderDrawLine(r[1][1], r[1][2], r[2][1], r[2][2], 2, 0xFFff004d)
        renderDrawLine(r[2][1], r[2][2], r[3][1], r[3][2], 2, 0xFFff004d)
        renderDrawLine(r[3][1], r[3][2], r[4][1], r[4][2], 2, 0xFFff004d)
        renderDrawLine(r[4][1], r[4][2], r[1][1], r[1][2], 2, 0xFFff004d)

        renderDrawLine(r[5][1], r[5][2], r[8][1], r[8][2], 2, 0xFFff004d)
        renderDrawLine(r[8][1], r[8][2], r[7][1], r[7][2], 2, 0xFFff004d)
        renderDrawLine(r[6][1], r[6][2], r[5][1], r[5][2], 2, 0xFFff004d)
        renderDrawLine(r[7][1], r[7][2], r[6][1], r[6][2], 2, 0xFFff004d)

        renderDrawLine(r[1][1], r[1][2], r[5][1], r[5][2], 2, 0xFFff004d)
        renderDrawLine(r[2][1], r[2][2], r[6][1], r[6][2], 2, 0xFFff004d)
        renderDrawLine(r[3][1], r[3][2], r[7][1], r[7][2], 2, 0xFFff004d)
        renderDrawLine(r[4][1], r[4][2], r[8][1], r[8][2], 2, 0xFFff004d)
    end
end

function debugRenderCarCube(car, func, color)
    if doesVehicleExist(car) then
        local c = func(getCarModel(car), car)

        local r = {}
        for k, v in pairs(c) do
            r[k] = { convert3DCoordsToScreen(table.unpack(v)) }
        end

        for i = 1, #r do
            renderDrawPolygon(r[i][1] - 2, r[i][2] - 2, 10, 10, 10, 0, color)
            renderFontDrawText(font, 'Corner #' .. i, r[i][1], r[i][2], 0xFFFFFFFF, 0x90000000)
        end

        renderDrawLine(r[1][1], r[1][2], r[2][1], r[2][2], 2, color)
        renderDrawLine(r[2][1], r[2][2], r[3][1], r[3][2], 2, color)
        renderDrawLine(r[3][1], r[3][2], r[4][1], r[4][2], 2, color)
        renderDrawLine(r[4][1], r[4][2], r[1][1], r[1][2], 2, color)

        renderDrawLine(r[5][1], r[5][2], r[8][1], r[8][2], 2, color)
        renderDrawLine(r[8][1], r[8][2], r[7][1], r[7][2], 2, color)
        renderDrawLine(r[6][1], r[6][2], r[5][1], r[5][2], 2, color)
        renderDrawLine(r[7][1], r[7][2], r[6][1], r[6][2], 2, color)

        renderDrawLine(r[1][1], r[1][2], r[5][1], r[5][2], 2, color)
        renderDrawLine(r[2][1], r[2][2], r[6][1], r[6][2], 2, color)
        renderDrawLine(r[3][1], r[3][2], r[7][1], r[7][2], 2, color)
        renderDrawLine(r[4][1], r[4][2], r[8][1], r[8][2], 2, color)
    end
end

--------------------------------------------------------------------------------
-------------------------------------MENU---------------------------------------
--------------------------------------------------------------------------------
function callMenu(pos)
    sampShowDialog(0)
    sampCloseCurrentDialogWithButton(0)
    openMenu(pos)
end

function openLink(link)
    local ffi = require 'ffi'
    ffi.cdef [[
            void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
            uint32_t __stdcall CoInitializeEx(void*, uint32_t);
        ]]
    local shell32 = ffi.load 'Shell32'
    local ole32 = ffi.load 'Ole32'
    ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
    sampAddChatMessage("opening link in your browser: " .. link, -1)
    print(shell32.ShellExecuteA(nil, 'open', link, nil, nil, 1))
end

function openMenu(pos)
    -- original snippet by fyp, but was slighty modified
    local function submenus_show(menu, caption, select_button, close_button, back_button, pos)
        select_button, close_button, back_button = select_button or 'Select', close_button or 'Close',
            back_button or 'Back'
        prev_menus = {}
        function display(menu, id, caption, pos)
            local string_list = {}
            for i, v in ipairs(menu) do
                table.insert(string_list, type(v.submenu) == 'table' and v.title .. '  >>' or v.title)
            end
            sampShowDialog(id, caption, table.concat(string_list, '\n'), select_button,
                (#prev_menus > 0) and back_button or close_button, 4)
            if pos then
                sampSetCurrentDialogListItem(pos)
                if pos > 16 then
                    setVirtualKeyDown(40, true)
                    setVirtualKeyDown(40, false)
                    setVirtualKeyDown(38, true)
                    setVirtualKeyDown(38, false)
                end
            end
            repeat
                wait(0)
                local result, button, list = sampHasDialogRespond(id)
                if result then
                    if button == 1 and list ~= -1 then
                        local item = menu[list + 1]
                        if type(item.submenu) == 'table' then -- submenu
                            table.insert(prev_menus, { menu = menu, caption = caption, pos = list })
                            if type(item.onclick) == 'function' then
                                item.onclick(menu, list + 1, item.submenu)
                            end
                            return display(item.submenu, id + 1, item.submenu.title and item.submenu.title or item.title)
                        elseif type(item.onclick) == 'function' then
                            local result = item.onclick(menu, list + 1)
                            if not result then return result end
                            return display(menu, id, caption, list)
                        else
                            return display(menu, id, caption, list)
                        end
                    else -- if button == 0
                        if #prev_menus > 0 then
                            local prev_menu = prev_menus[#prev_menus]
                            prev_menus[#prev_menus] = nil
                            return display(prev_menu.menu, id - 1, prev_menu.caption, prev_menu.pos)
                        end
                        return false
                    end
                end
            until result
        end

        return display(menu, 31337, caption or menu.title, pos)
    end

    local function mergeMenu(mod, all)
        for k, v in pairs(all) do
            table.insert(mod, v)
        end
    end

    local function createLinkRow(title, link)
        return {
            title = title,
            onclick = function()
                openLink(link)
                return true
            end
        }
    end

    local function createEmptyLine()
        return {
            title = " "
        }
    end

    local function generateStatusString(numBars, maxBars)
        local statusString = "["
        local bar = "|"
        local emptyBar = " "

        -- Calculate the number of empty bars needed
        local numEmptyBars = maxBars - numBars

        -- Add "|" characters to the status string
        for i = 1, numBars do
            statusString = statusString .. bar
        end

        -- Add empty bars to the status string
        for i = 1, numEmptyBars do
            statusString = statusString .. emptyBar
        end

        statusString = statusString .. "] " .. tostring(numBars) .. "/" .. tostring(maxBars)

        return statusString
    end

    local function createSimpleToggle(group, setting, text, disabled, func)
        return {
            title = (disabled and "{696969}" or "") .. text .. ": " .. tostring(cfg[group][setting]),
            onclick = function(menu, row)
                cfg[group][setting] = not cfg[group][setting]
                saveCfg()
                menu[row].title = (disabled and "{696969}" or "") .. text .. ": " .. tostring(cfg[group][setting])
                if not func then
                    return true
                else
                    return func(cfg[group][setting], menu, row)
                end
            end
        }
    end

    local function createSimpleSlider(group, setting, text, caption, button1, min, max, stepCoof, funcOnChange, funcOnEnd)
        return {
            title = text .. ": " .. tostring(cfg[group][setting]),
            onclick = function(menu, row)
                if cfg[group][setting] < min then
                    cfg[group][setting] = min
                end
                sampShowDialog(767, caption, generateStatusString(cfg[group][setting], max), button1)

                while sampIsDialogActive(767) do
                    wait(100)
                    if sampIsDialogActive(767) and (isKeyDown(0x25) or isKeyDown(0x26) or isKeyDown(0x27) or isKeyDown(0x28)) then
                        local step = 0
                        if isKeyDown(0x27) then
                            step = 1
                        elseif isKeyDown(0x26) then
                            step = 5
                        elseif isKeyDown(0x25) then
                            step = -1
                        elseif isKeyDown(0x28) then
                            step = -5
                        end

                        local newValue = cfg[group][setting] + step * stepCoof
                        if newValue < min then
                            newValue = min
                        elseif newValue > max then
                            newValue = max
                        end
                        cfg[group][setting] = newValue

                        if funcOnChange then
                            funcOnChange(cfg[group][setting])
                        end

                        sampShowDialog(767, caption, generateStatusString(cfg[group][setting], max), button1)
                    end
                end

                menu[row].title = text .. ": " .. tostring(cfg[group][setting])

                if not funcOnEnd then
                    return true
                else
                    return funcOnEnd(cfg[group][setting], menu, row)
                end
            end
        }
    end

    local function createCubeAdjuster(group, setting1, setting2, setting3, setting4, setting5, setting6, text, caption,
                                      button1, min, max,
                                      stepCoof, funcOnRender, funcOnChange, funcOnEnd)
        local function generateText()
            local str = ''

            for k, v in pairs({
                {
                    m = "cubeSlider1", k = setting1
                },
                {
                    m = "cubeSlider2", k = setting2
                },
                {
                    m = "cubeSlider3", k = setting3
                },
                {
                    m = "cubeSlider4", k = setting4
                },
                {
                    m = "cubeSlider5", k = setting5
                },
                {
                    m = "cubeSlider6", k = setting6
                }
            }) do
                str = str .. getMessage(v.m) .. " " .. generateStatusString(cfg[group][v.k], max) .. "\n"
            end
            return str
        end
        return {
            title = text,
            onclick = function(menu, row)
                for k, v in pairs({ setting1, setting2, setting3, setting4, settings5, setting6 }) do
                    if cfg[group][v] < min then
                        cfg[group][v] = min
                    end
                end

                sampShowDialog(767, caption, generateText(), button1)

                if funcOnRender then
                    table.insert(tempThreads, lua_thread.create(function()
                        while sampIsDialogActive(767) do
                            wait(0)
                            funcOnRender()
                        end
                    end))
                end

                while sampIsDialogActive(767) do
                    wait(0)
                    if sampIsDialogActive(767) and (isKeyDown(0x25) or isKeyDown(0x26) or isKeyDown(0x27) or isKeyDown(0x28)) and (isKeyDown(0x31) or isKeyDown(0x32) or isKeyDown(0x33) or isKeyDown(0x34) or isKeyDown(0x35) or isKeyDown(0x36)) then
                        wait(100)
                        local settingToTweak = ''

                        if isKeyDown(0x31) then
                            settingToTweak = setting1
                        elseif isKeyDown(0x32) then
                            settingToTweak = setting2
                        elseif isKeyDown(0x33) then
                            settingToTweak = setting3
                        elseif isKeyDown(0x34) then
                            settingToTweak = setting4
                        elseif isKeyDown(0x35) then
                            settingToTweak = setting5
                        elseif isKeyDown(0x36) then
                            settingToTweak = setting6
                        end

                        local step = 0
                        if isKeyDown(0x27) then
                            step = 1
                        elseif isKeyDown(0x26) then
                            step = 5
                        elseif isKeyDown(0x25) then
                            step = -1
                        elseif isKeyDown(0x28) then
                            step = -5
                        end

                        if settingToTweak ~= '' then
                            local newValue = cfg[group][settingToTweak] + step * stepCoof
                            if newValue < min then
                                newValue = min
                            elseif newValue > max then
                                newValue = max
                            end
                            cfg[group][settingToTweak] = newValue

                            if funcOnChange then
                                funcOnChange(cfg[group][setting])
                            end

                            sampShowDialog(767, caption, generateText(), button1)
                        end
                    end
                end

                if not funcOnEnd then
                    return true
                else
                    return funcOnEnd(menu, row)
                end
            end
        }
    end

    --welcome section
    local function genSectionWelcome()
        return {
            {
                title = getMessage("desc"),
                onclick = function()
                    sampShowDialog(
                        0,
                        "{7ef3fa}/wraith v." .. thisScript().version,
                        getMessage('description'),
                        "OK"
                    )
                    while sampIsDialogActive() and sampGetCurrentDialogId() == 0 do wait(0) end
                    return true
                end
            },
            {
                title = getMessage("changeLang"),
                onclick = function(menu, row)
                    cfg.options.language = cfg.options.language == "ru" and "en" or "ru"
                    saveCfg()
                    printStringNow(getMessage('langChanged'), 1000)
                    callMenu()
                end
            }
        }
    end

    -- links section
    local function genSectionLinks()
        return {
            {
                title = getMessage("sectionLinks")
            },
            createLinkRow(getMessage("moreAboutScript"), "https://www.blast.hk/threads/198111/"),
            createLinkRow(getMessage("moreAboutSC"), "https://www.blast.hk/threads/193650/"),
        }
    end

    -- passive section
    local function genSectionPassive()
        return {
            {
                title = getMessage('sectionPassive')
            },
            createSimpleToggle("passive", "enable", getMessage("settingPassive"),
                cfg.passive.enable, function(value, menu, pos)
                    callMenu(pos - 1)
                    return false
                end),
            {
                title = (not cfg.passive.enable and "{696969}" or "") .. getMessage("passiveActivationMode") ..
                    (cfg.passive.enable and ("{00ff00}" .. getMessage("passiveActivationEnabled")) or getMessage("passiveActivationDisabled")),
            },
            -- passive settings
            {
                title = (not cfg.passive.enable and "{696969}" or "") .. getMessage("settingPassiveSection"),
                submenu = {
                    {
                        title = (not cfg.passive.enable and "{696969}" or "{808000}") ..
                            getMessage('settingPassiveSectionAimed')
                    },
                    createSimpleToggle("passive", "needAimLine", getMessage("settingPassiveNeedAimLine"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "showTempTracer", getMessage("settingPassiveTracer"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "printStyledString", getMessage("settingPassiveString"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "addOneOffSound", getMessage("settingPassiveAddOffSound"),
                        not cfg.passive.enable),
                    createEmptyLine(),

                    {
                        title = (not cfg.passive.enable and "{696969}" or "{808000}") ..
                            getMessage('settingPassiveSectionBullet')
                    },
                    createSimpleToggle("passive", "needBullet", getMessage("settingPassiveNeedBullet"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "showTempTracerB", getMessage("settingPassiveTracerB"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "printStyledStringB", getMessage("settingPassiveStringB"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "addOneOffSoundB", getMessage("settingPassiveAddOffSoundB"),
                        not cfg.passive.enable),
                    createEmptyLine(),

                    {
                        title = (not cfg.passive.enable and "{696969}" or "{808000}") ..
                            getMessage('settingPassiveSectionWarn')
                    },
                    createSimpleToggle("passive", "warnSoundRespectCooldown",
                        getMessage("settingWarnSoundRespectCooldown"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "showTempTracerWarn", getMessage("settingPassiveTracer"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "printStyledStringWarn", getMessage("settingPassiveString"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "warnAddOneOffSound", getMessage("settingPassiveWarnAddOffSound"),
                        not cfg.passive.enable),
                    {
                        title = (not cfg.passive.enable and "{696969}" or "") ..
                            getMessage('passiveSendChatWarnSetting') ..
                            ': ' ..
                            (cfg.passive.sendChatWarn ~= "" and ('\'' .. cfg.passive.sendChatWarn .. '\'') or getMessage('settingPassiveChatWarnEmpty')),
                        onclick = function(menu, row)
                            sampShowDialog(778, getMessage('passiveSendChatWarnCaption'),
                                getMessage('passiveSendChatWarnText'),
                                getMessage('legacyChangeKeyButton1'), getMessage('legacyChangeKeyButton2'), 1)
                            sampSetCurrentDialogEditboxText(cfg.passive.sendChatWarn)
                            while sampIsDialogActive(778) do
                                wait(100)
                            end
                            local resultMain, buttonMain, typ, input = sampHasDialogRespond(778)
                            cfg.passive.sendChatWarn = input
                            saveCfg()

                            if buttonMain == 1 then
                                menu[row].title = (not cfg.passive.enable and "{696969}" or "") ..
                                    getMessage('passiveSendChatWarnSetting') ..
                                    ': ' ..
                                    (cfg.passive.sendChatWarn ~= "" and ('\'' .. cfg.passive.sendChatWarn .. '\'') or getMessage('settingPassiveChatWarnEmpty'))
                                return true
                            else
                                return true
                            end
                        end
                    },

                    createSimpleSlider("passive", "cooldown",
                        (not cfg.passive.enable and "{696969}" or "") .. getMessage('settingPassiveCooldown'),
                        getMessage('settingPassiveCooldownCaption'), "OK", 6, 100,
                        1, function(v)
                            saveCfg()
                        end),

                    createEmptyLine(),

                    { title = (not cfg.passive.enable and "{696969}" or "{808000}") .. 'settings' },
                    createSimpleToggle("passive", "smartTracer", getMessage("settingPassiveSmartTracer"),
                        not cfg.passive.enable),

                    createSimpleSlider("passive", "reactDuration",
                        (not cfg.passive.enable and "{696969}" or "") .. getMessage('settingPassiveDuration'),
                        getMessage('settingPassiveDurationCaption'), "OK", 1, 20,
                        1, function(v)
                            saveCfg()
                        end),

                    createSimpleToggle("passive", "needBulletRectangleCuboidFoot",
                        getMessage("settingPassiveNeedBulletRectangleCuboidFoot"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "needBulletRectangleCuboidCar",
                        getMessage("settingPassiveNeedBulletRectangleCuboidCar"),
                        not cfg.passive.enable),

                    createSimpleToggle("passive", "needAimLineRectangleCuboidFoot",
                        getMessage("settingPassiveNeedAimLineRectangleCuboidFoot"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "needAimLineRectangleCuboidCar",
                        getMessage("settingPassiveNeedAimLineRectangleCuboidCar"),
                        not cfg.passive.enable),

                    createCubeAdjuster('passive', 'p1', 'p2', 'p3', 'p4', 'p5', 'p6',
                        (not cfg.passive.enable and "{696969}" or "") .. getMessage('settingPassiveCharCube'),
                        getMessage('settingPassiveCharCubeCaption'), 'ok', 0.1, 10,
                        0.1,
                        function()
                            if doesCharExist(playerPed) then
                                debugRenderCharCube(playerPed)
                            end
                        end, nil, function()
                            saveCfg()
                            return true
                        end),
                    createCubeAdjuster('passive', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6',
                        (not cfg.passive.enable and "{696969}" or "") .. getMessage('settingPassiveCarCube'),
                        getMessage('settingPassiveCarCubeCaption'), 'ok', 0.1, 10,
                        0.1,
                        function()
                            if isCharInAnyCar(PLAYER_PED) then
                                debugRenderCarCube(storeCarCharIsInNoSave(playerPed), getCarModelCorners, "0xFFffff4d")
                                --debugRenderCarCube(storeCarCharIsInNoSave(playerPed), getCarModelCornersStable, "0xFFff004d")
                            end
                        end, nil, function()
                            saveCfg()
                            return true
                        end)
                },
            }
        }
    end

    -- tactical section
    local function genSectionTactical()
        return {
            {
                title = getMessage('sectionTactical')
            },

            sampIsChatCommandDefined('wraith-tactical') and
            {
                title = getMessage('openWraithTactical'),
                onclick = function()
                    sampProcessChatInput('/wraith-tactical')
                end
            } or
            createLinkRow(getMessage("openWraithTacticalThread"), "https://www.blast.hk/threads//")
        }
    end

    -- settings section
    local function genSectionSettings()
        return {
            {
                title = getMessage("sectionSettings")
            },
            createSimpleToggle("options", "welcomeMessage", getMessage('settingWelcomeMessage'), false)
        }
    end

    local function genSectionMisc()
        return {
            {
                title = getMessage("sectionMisc")
            },

            createLinkRow(getMessage("debugScriptXiaomi"), "https://www.blast.hk/threads/198256/"),
            createLinkRow(getMessage("debugScriptAimline"), "https://www.blast.hk/threads/198312/"),
            createLinkRow(getMessage("openGithub"), "https://github.com/qrlk/wraith.lua"),

            {
                title = getMessage("unloadScript"),
                onclick = function()
                    printStringNow('wraith.lua terminated :c', 1000)
                    requestToUnload = true
                end
            }
        }
    end

    local mod_submenus_sa = {}

    mergeMenu(mod_submenus_sa, genSectionWelcome())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionLinks())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionPassive())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionTactical())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionSettings())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionMisc())

    submenus_show(mod_submenus_sa,
        "{348cb2}/wraith v." .. thisScript().version .. " || BLASTHACK SC23 2nd PLACE", getMessage("button1"),
        getMessage("button2"), getMessage("button3"),
        pos)
end

--3rd party
function getweaponname(weapon)
    local names = {
        [0] = "Fist",
        [1] = "Brass Knuckles",
        [2] = "Golf Club",
        [3] = "Nightstick",
        [4] = "Knife",
        [5] = "Baseball Bat",
        [6] = "Shovel",
        [7] = "Pool Cue",
        [8] = "Katana",
        [9] = "Chainsaw",
        [10] = "Purple Dildo",
        [11] = "Dildo",
        [12] = "Vibrator",
        [13] = "Silver Vibrator",
        [14] = "Flowers",
        [15] = "Cane",
        [16] = "Grenade",
        [17] = "Tear Gas",
        [18] = "Molotov Cocktail",
        [22] = "9mm",
        [23] = "Silenced 9mm",
        [24] = "Desert Eagle",
        [25] = "Shotgun",
        [26] = "Sawnoff Shotgun",
        [27] = "Combat Shotgun",
        [28] = "Micro SMG/Uzi",
        [29] = "MP5",
        [30] = "AK-47",
        [31] = "M4",
        [32] = "Tec-9",
        [33] = "Country Rifle",
        [34] = "Sniper Rifle",
        [35] = "RPG",
        [36] = "HS Rocket",
        [37] = "Flamethrower",
        [38] = "Minigun",
        [39] = "Satchel Charge",
        [40] = "Detonator",
        [41] = "Spraycan",
        [42] = "Fire Extinguisher",
        [43] = "Camera",
        [44] = "Night Vis Goggles",
        [45] = "Thermal Goggles",
        [46] = "Parachute"
    }
    return names[weapon]
end
