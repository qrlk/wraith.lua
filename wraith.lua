require 'lib.moonloader'

script_name("wraith.lua")
script_author("qrlk")
script_description("wraith passive + tactical")
-- made for https://www.blast.hk/threads/193650/
script_url("https://github.com/qrlk/wraith.lua")
script_version("23.12.2023-rc3")

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true     -- false to disable error reports to sentry.io
-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)

--^^ none of it works if wraith.lua is loaded as a module.
local mod = {}
do
    mod._VERSION = "0.0.1"

    mod.aspectRatios = {
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

    mod.approximateAspectRatio = { {
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

    mod.getRealAspectRatioByWeirdValue = function(aspectRatio)
        local hit = false
        if mod.aspectRatios[aspectRatio] ~= nil then
            hit = true
            return hit, mod.aspectRatios[aspectRatio]
        end
        for k, v in pairs(mod.approximateAspectRatio) do
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

    mod.anglesPerAspectRatio = {
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

    mod.getCurrentWeaponAngle = function(aspect, weapon)
        if aspect == "unknown" then
            aspect = "4:3"
        end

        if (weapon >= 22 and weapon <= 29) or weapon == 32 then
            return { mod.anglesPerAspectRatio[aspect].curxy, mod.anglesPerAspectRatio[aspect].curz }
        elseif weapon == 30 or weapon == 31 then
            return { mod.anglesPerAspectRatio[aspect].curARxy, mod.anglesPerAspectRatio[aspect].curARz }
        elseif weapon == 33 then
            return { mod.anglesPerAspectRatio[aspect].curRFxy, mod.anglesPerAspectRatio[aspect].curRFz }
        end

        return { 0.0, 0.0 }
    end

    mod.processAimLine = function(data, aspect)
        -- data.weapon
        local currentWeaponAngle = mod.getCurrentWeaponAngle(aspect, data.weapon)

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
end

if pcall(debug.getlocal, 4, 1) then
    return mod
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
local sampev = require "lib.samp.events"
local aspectRatioKey = sampev.MODULEINFO.version >= 3 and 'aspectRatio' or 'unknown'
local key = require 'vkeys'

local as_action = require('moonloader').audiostream_state

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

        sectionAudio = {
            en = "Audio",
            ru = "Аудио"
        },

        settingNoRadio = {
            en = "Block radio selection in vehicles",
            ru = "Блокировать выбор радио в машине"
        },
        checkAudioOff = {
            en = "radio off",
            ru = "радио выключено"
        },
        checkAudioOffNeedReboot = {
            en = "radio on, pls restart the game",
            ru = "радио вкл, но надо перезайти в игру"
        },
        checkAudioOn = {
            en = "radio",
            ru = "радио"
        },
        checkResourcesYes = {
            en = "resources",
            ru = "ресурсы"
        },
        checkResourcesNo = {
            en = "resources not found",
            ru = "ресурсы не найдены"
        },
        settingAudioEnable = {
            en = "Enable audio effects",
            ru = "Включить аудиоэффекты"
        },
        settingIgnoreMissing = {
            en = "Ignore missing sounds",
            ru = "Игнорировать ненайденные звуки"
        },

        settingAudioLanguage = {
            en = "Audio language",
            ru = "Язык аудио"
        },
        settingVolume = {
            en = "Base sound volume",
            ru = "Базовая громкость звуков"
        },
        lang = {
            en = "Audio lang: ",
            ru = "Язык аудио: "
        },
        settingVolumeCaption = {
            en = "Set preffered volume. Use your keyboard arrows.",
            ru = "Настройка громкости. Используйте стрелки клавиатуры."
        },

        settingVolumeQuietOffset = {
            en = "Increased volume for quiet sounds",
            ru = "Увеличение для тихих звуков"
        },
        settingVolumeQuietOffsetCaption = {
            en = "Set preffered volume. Use your keyboard arrows.",
            ru = "Настройка громкости. Используйте стрелки клавиатуры."
        },

        randomSound = {
            en = "Example: ",
            ru = "Пример: "
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

        settingPassiveTracer = {
            en = "Show temporary tracer to enemy when ability is triggered",
            ru = "Показывать временный трасер"
        },
        settingPassiveString = {
            en = "Show gametext warning when ability is triggered",
            ru = "Показывать gametext строку"
        },

        settingPassiveCooldown = {
            en = "Passive ability cooldown (in seconds)",
            ru = "Кулдаун пассивной способности (в сек.)"
        },

        settingPassiveCooldownCaption = {
            en = "Set passive cooldown. Use your keyboard arrows.",
            ru = "Настройка кулдауна пассивной. Используйте стрелки клавиатуры."
        },

        tacticalUnderZWarning = {
            en = 'YOU ARE UNDER GROUND!!!',
            ru = 'VI POD ZEMLEY!!!'
        },

        sectionTactical = {
            en = "{808000}Tactical ability - Into the Void",
            ru = "{808000}Тактическая способность - В Пустоту"
        },

        settingTactical = {
            en = "Into the Void {ff0000}(easily detectable cheat){ffffff}",
            ru = "В Пустоту {ff0000}(очень палевный чит){ffffff}"
        },
        --todo
        tooltipSettingTacticalEnable = {
            en = "Reposition quickly through the safety of void space, avoiding all damage.",
            ru = "Быстро перемещает вас сквозь Пустоту, позволяя избежать урона."
        },

        settingTacticalAlt = {
            en = "Need to press LEFT ALT to activate",
            ru = "Нужно зажать LEFT ALT для активации"
        },

        settingTacticalSection = {
            en = "Tactical Ability Settings",
            ru = "Настройки тактической способности"
        },
        settingTacticalCooldownCaption = {
            en = "Set tactical cooldown. Use your keyboard arrows.",
            ru = "Настройка кулдауна тактической. Используйте стрелки клавиатуры."
        },
        settingTacticalInstant = {
            en = "Remove delay before activation",
            ru = "Убрать задержку перед активацией"
        },

        phasingStart1 = {
            en = "PHASING.. HOLD ",
            ru = "PHASING.. DERJI "
        },
        phasingStart2 = {
            en = " TO CANCEL",
            ru = " DLYA OTMENI"
        },
        phasingCanceled = {
            en = "PHASING CANCELLED",
            ru = "OTMEHA"
        },

        settingTacticalCooldown = {
            en = "Tactical ability cooldown (in seconds)",
            ru = "Кулдаун тактической способности (в сек.)"
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

        tacticalActivationMode = {
            en = "Activation: ",
            ru = "Активация: "
        },
        tacticalActivationDisabled = {
            en = "ability disabled",
            ru = "способность отключена"
        },

        tacticalKeyName = {
            en = "Main key for activation: ",
            ru = "Основная кнопка для активации: "
        },

        legacyChangeKeyTitle = {
            en = "Changing hotkey",
            ru = "Изменение горячей клавиши"
        },

        legacyChangeKeyText = {
            en = 'Click "OK" and then press the desired key.\nThe setting will be changed.',
            ru = 'Нажмите "Окей", после чего нажмите нужную клавишу.\nНастройки будут изменены.'
        },

        legacyChangeKeyButton1 = {
            en = "OK",
            ru = "Окей"
        },

        legacyChangeKeyButton2 = {
            en = "Cancel",
            ru = "Отмена"
        },
        legacyChangeKeySuccess = {
            en = "A new hotkey has been installed - ",
            ru = "Установлена новая горячая клавиша - "
        },

        cantFindResources = {
            en = "Can't find: ",
            ru = "Не могу найти: "
        },

        pleaseDownloadResources = {
            en = 'Download the resources from http://qrlk.me/wraith and place them in your moonloader folder!',
            ru = 'Скачайте архив с ресурсами с http://qrlk.me/wraith и поместите в папку moonloader!'
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
        }

    },
    audioLangTable = {
        en = { 'English', 'Russian', 'French', 'Italian', 'German', 'Spanish', 'Japanese', 'Korean', 'Polish', 'Chinese' },
        ru = { 'Английский', 'Русский', 'Французский', 'Итальянский',
            'Немецкий', 'Испанский', 'Японский', 'Корейский',
            'Польский', 'Китайский' }
    }
}

--
local audioLanguages = { 'en', 'ru', 'fr', 'it', 'de', 'es', 'ja', 'ko', 'pl', 'zh' }
local audioLines = {
    aiming = { "diag_mp_wraith_voices_seesPlayer_urgent_01_01_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_01_02_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_02_01_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_02_02_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_02_03_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_03_01_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_03_02_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_04_01_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_04_02_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_05_01_1p.mp3",
        "diag_mp_wraith_voices_seesPlayer_urgent_05_02_1p.mp3" },
    lol = { "diag_mp_wraith_bc_locationAWH_01_01_1p.mp3", "diag_mp_wraith_bc_locationAWH_01_02_1p.mp3" },
    no = { "diag_mp_wraith_ping_no_01_01_1p.mp3", "diag_mp_wraith_ping_no_01_02_1p.mp3",
        "diag_mp_wraith_ping_no_01_03_1p.mp3", "diag_mp_wraith_ping_no_02_01_1p.mp3",
        "diag_mp_wraith_ping_no_02_02_1p.mp3", "diag_mp_wraith_ping_no_02_03_1p.mp3" },
    notReady = { "diag_mp_wraith_ping_ultUpdate_notReady_calm_01_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_calm_01_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_03_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_03_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_03_1p.mp3" },
    isReady = { "diag_mp_wraith_ping_ultUpdate_isReady_calm_01_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_01_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_01_03_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_01_04_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_01_05_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_02_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_02_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_calm_02_03_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_urgent_01_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_urgent_01_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_urgent_02_01_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_urgent_02_02_1p.mp3",
        "diag_mp_wraith_ping_ultUpdate_isReady_urgent_02_03_1p.mp3" },
    sniper = { "diag_mp_wraith_voices_sniper_urgent_01_01_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_01_02_1p.mp3",
        "diag_mp_wraith_voices_sniper_urgent_01_03_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_02_01_1p.mp3",
        "diag_mp_wraith_voices_sniper_urgent_02_02_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_02_03_1p.mp3",
        "diag_mp_wraith_voices_sniper_urgent_03_01_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_03_02_1p.mp3",
        "diag_mp_wraith_voices_sniper_urgent_03_03_1p.mp3" },
    tactical = { "diag_mp_wraith_bc_tactical_01_01_1p.mp3", "diag_mp_wraith_bc_tactical_01_02_1p.mp3",
        "diag_mp_wraith_bc_tactical_01_03_1p.mp3", "diag_mp_wraith_bc_tactical_02_01_1p.mp3",
        "diag_mp_wraith_bc_tactical_02_02_1p.mp3", "diag_mp_wraith_bc_tactical_02_03_1p.mp3",
        "diag_mp_wraith_bc_tactical_03_01_1p.mp3", "diag_mp_wraith_bc_tactical_03_02_1p.mp3",
        "diag_mp_wraith_bc_tactical_03_03_1p.mp3", "diag_mp_wraith_bc_tactical_04_01_1p.mp3",
        "diag_mp_wraith_bc_tactical_04_02_1p.mp3", "diag_mp_wraith_bc_tactical_04_03_1p.mp3" },
    vehicle = { "diag_mp_wraith_voices_hostiles_urgent_01_01_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_01_02_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_01_03_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_02_01_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_02_02_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_03_01_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_03_02_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_03_03_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_04_01_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_04_02_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_04_03_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_05_01_1p.mp3",
        "diag_mp_wraith_voices_hostiles_urgent_05_02_1p.mp3" }
}

local cfg = inicfg.load({
    options = {
        welcomeMessage = true,
        language = defaultLanguage,
    },
    audio = {
        language = defaultLanguage,
        enable = true,
        volume = 5,
        quietOffset = 5,
        noRadio = false,
        ignoreMissing = false
    },
    tactical = {
        enable = false,
        alt = true,
        instant = false,
        key = 0x51,
        cooldown = 15
    },
    passive = {
        enable = true,
        printStyledString = true,
        showTempTracer = true,
        cooldown = 20
    }
}, 'wraith')

function getMessage(key)
    if i18n.data[key][cfg.options.language] ~= nil then
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

local wraith_passive_lastused = 0
local needToTriggerAimedPed = false
local needToTriggerAimedPedSniper = false
local needToTriggerAimedVehicle = false
local wraith_passive_triggeredbyped = false

local wraith_tactical_active = false
local wraith_tactical_lastused = 0
local wraith_tactical_weather = 478
local wraith_tactical_hour = 14

local requestToUnload = false

-- the aspect ratio snippet is being worked on here:  https://www.blast.hk/threads/198256/ https://github.com/qrlk/wraith-xiaomi

-- trying to ulitize aspectRatio property from aimSync

local mainSoundStream = loadAudioStream()
local reserveSoundStream = loadAudioStream()

local CURRENT_RANDOM_SOUND = ""

local radio_were_disabled = false

local phasingSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\tactical.mp3"
local phasingInstantSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\tactical_instant.mp3"

function main()
    if not isCleoLoaded() then
        printStyledString('wraith.lua: pls install cleo', 5000, 2)
        return
    end
    if not isSampfuncsLoaded() then
        printStyledString('wraith.lua: pls install sampfuncs', 5000, 5)
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
        local str = "You must update moonloader if you want to use wraith.lua"
        printStyledString(str, 10000, 2)
        printStyledString(str, 10000, 5)
        thisScript():unload()
        wait(-1)
    end

    -- sc23

    if getVolume().radio == 0 then
        radio_were_disabled = true
    end

    sampRegisterChatCommand('wraith', function()
        table.insert(tempThreads, lua_thread.create(function()
            if cfg.audio.enable and cfg.options.welcomeMessage then
                if not checkAudioResources() then
                    sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
                end
                if getVolume().radio == 0 and cfg.audio.volume ~= 0 then
                    sampAddChatMessage(getMessage('radioDisabledWarning'), 0x7ef3fa)
                end
            end
            callMenu()
        end))
    end)

    sampProcessChatInput('/wraith')

    while sampGetCurrentServerName() == "SA-MP" do
        wait(500)
    end
    if cfg.options.welcomeMessage then
        sampAddChatMessage(getMessage('welcomeMessage'), 0x7ef3fa)

        if cfg.audio.enable then
            if not checkAudioResources() and cfg.audio.enable then
                sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
            end

            if getVolume().radio == 0 and cfg.audio.volume ~= 0 then
                sampAddChatMessage(getMessage('radioDisabledWarning'), 0x7ef3fa)
            end
        end

        if cfg.tactical.enable then
            playRandomFromCategory('isReady')
        end
    end

    if cfg.audio.noRadio then
        writeMemory(0x4EB9A0, 3, 1218, true)
    end

    while true do
        wait(0)

        if cfg.tactical.enable then
            processTactical()
        end

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
function processPassive()
    -- TODO: rework wraith_passive_triggeredbyped logic
    if needToTriggerAimedPed then
        needToTriggerAimedPed = false
        if cfg.passive.enable and os.clock() - cfg.passive.cooldown > wraith_passive_lastused then
            triggerPassive('aiming', wraith_passive_triggeredbyped)
        end
    end

    if needToTriggerAimedPedSniper then
        needToTriggerAimedPedSniper = false
        if cfg.passive.enable and os.clock() - cfg.passive.cooldown > wraith_passive_lastused then
            triggerPassive('sniper', wraith_passive_triggeredbyped)
        end
    end

    if needToTriggerAimedVehicle then
        needToTriggerAimedVehicle = false
        if cfg.passive.enable and os.clock() - cfg.passive.cooldown > wraith_passive_lastused then
            triggerPassive('vehicle', wraith_passive_triggeredbyped)
        end
    end
end

function triggerPassive(typ, enemyPed)
    wraith_passive_lastused = os.clock()
    if doesCharExist(enemyPed) then
        local _, id = sampGetPlayerIdByCharHandle(enemyPed)
        if _ and sampIsPlayerConnected(id) then
            local nick = sampGetPlayerNickname(id)
            local x, y, z = getCharCoordinates(playerPed)
            local mX, mY, mZ = getCharCoordinates(enemyPed)

            local dist = math.floor(getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ))
            if typ == "aiming" then
                playRandomFromCategory('aiming')
                if cfg.passive.printStyledString then
                    printStyledString(string.format("AIMED by %s [%s] (%sm)", nick, id, dist), 5000, 5)
                end
            elseif typ == "sniper" then
                playRandomFromCategory('sniper')
                if cfg.passive.printStyledString then
                    printStyledString(string.format("SNIPER!!! %s [%s] (%sm)", nick, id, dist), 3000, 5)
                end
            elseif typ == "vehicle" then
                playRandomFromCategory('vehicle')
                if cfg.passive.printStyledString then
                    printStyledString(string.format("DANGER!!! %s [%s] (%sm)", nick, id, dist), 3000, 5)
                end
            end

            if cfg.passive.showTempTracer and enemyPed then
                table.insert(tempThreads, lua_thread.create(createTemporaryTracer, enemyPed, 5))
            end
        end
    end
end

--tactical
function processTactical()
    if ((isKeyDown(0xA4) or not cfg.tactical.alt) and wasKeyPressed(cfg.tactical.key)) then
        if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if isCharOnFoot(playerPed) and not isCharDead(playerPed) then
                if os.clock() - cfg.tactical.cooldown > wraith_tactical_lastused then
                    table.insert(tempThreads, lua_thread.create(function()
                        if cfg.tactical.instant then
                            if cfg.tactical.key ~= 0x51 or readMemory(getCharPointer(playerPed) + 0x528, 1, false) ==
                                19 then
                                wait(200)
                            else
                                wait(100)
                                setGameKeyState(7, 1)
                                wait(100)
                            end

                            playReserveSoundNow(phasingInstantSoundPath)
                            wait(50)
                            playRandomFromCategory('tactical')
                        else
                            playReserveSoundNow(phasingSoundPath)
                            -- todo fix dry

                            printStyledString(getMessage('phasingStart1') .. key.id_to_name(cfg.tactical.key) ..
                                getMessage('phasingStart2'), 2000, 5)
                            if cfg.tactical.key ~= 0x51 or readMemory(getCharPointer(playerPed) + 0x528, 1, false) ==
                                19 then
                                wait(200)
                            else
                                wait(100)
                                setGameKeyState(7, 1)
                                wait(100)
                            end

                            wait(500)
                            playRandomFromCategory('tactical')
                            wait(1500)
                        end
                        if not cfg.tactical.instant and isKeyDown(cfg.tactical.key) then
                            wraith_tactical_active = false
                            printStyledString(getMessage('phasingCanceled'), 2000, 5)
                            stopReserveSoundNow()
                            playRandomFromCategory('no')
                            wait(2000)
                        else
                            local weaponToRestore = getCurrentCharWeapon(playerPed)
                            local hoursToRestore, minsToRestore = getTimeOfDay()
                            local weatherToRestore = readMemory(0xC81320, 2, true)
                            local chatDisplayModeToRestore = sampGetChatDisplayMode()

                            setCurrentCharWeapon(playerPed, 0)
                            forceWeatherNow(wraith_tactical_weather)

                            wraith_tactical_active = true
                            displayHud(false)
                            sampSetChatDisplayMode(0)

                            table.insert(tempThreads, lua_thread.create(function()
                                while wraith_tactical_active and not isCharDead(playerPed) do
                                    wait(0)
                                    setTimeOfDay(wraith_tactical_hour, 0)
                                    if isCharDead(playerPed) then
                                        wraith_tactical_active = false
                                    end
                                end
                                setTimeOfDay(hoursToRestore, minsToRestore)
                                forceWeatherNow(weatherToRestore)

                                displayHud(true)
                                sampSetChatDisplayMode(chatDisplayModeToRestore)
                            end))

                            while wraith_tactical_active and not isCharDead(playerPed) do
                                wait(0)
                                setGameKeyState(5, 0)
                                setGameKeyState(6, 0)
                                setGameKeyState(7, 0)
                                setGameKeyState(14, 0)
                                setGameKeyState(15, 0)
                                setGameKeyState(17, 0)
                            end

                            if hasCharGotWeapon(playerPed, weaponToRestore) then
                                setCurrentCharWeapon(playerPed, weaponToRestore)
                            end
                        end
                    end))

                    -- blocking passive because we are underground
                    local start_wait = os.clock()
                    wait(4000)
                    while os.clock() - start_wait < (cfg.tactical.instant and 4.5 or 6.5) do
                        wait(0)
                        if wraith_tactical_active then
                            wait(100)
                        else
                            break
                        end
                    end

                    if wraith_tactical_active then
                        wraith_tactical_active = false
                        wraith_tactical_lastused = os.clock()
                    end
                else
                    -- cooldown voiceline
                    playRandomFromCategory('notReady')
                    local left = math.floor(cfg.tactical.cooldown - (os.clock() - wraith_tactical_lastused))
                    printStringNow(string.format('%sc', left), 3000)
                end
            end
        end
    end
end

-- sampev replacement

-- function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
--     if id == 203 then
--         local packetId = raknetBitStreamReadInt8(bitStream)
--         local camMode = raknetBitStreamReadInt8(bitStream)
--         local camFrontX = raknetBitStreamReadFloat(bitStream)
--         local camFrontY = raknetBitStreamReadFloat(bitStream)
--         local camFrontZ = raknetBitStreamReadFloat(bitStream)
--         local camPosX = raknetBitStreamReadFloat(bitStream)
--         local camPosY = raknetBitStreamReadFloat(bitStream)
--         local camPosZ = raknetBitStreamReadFloat(bitStream)
--         local aimZ = raknetBitStreamReadFloat(bitStream)
--         local int8 = raknetBitStreamReadInt8(bitStream)
--         local weaponState = math.floor(int8 / 64) % 4
--         local camExtZoom = int8 % 64
--         local aspectRatio = raknetBitStreamReadInt8(bitStream)

--         local data = {
--             camMode = camMode,
--             camFrontX = camFrontX,
--             camFrontY = camFrontY,
--             camFrontZ = camFrontZ,
--             camPosX = camPosX,
--             camPosY = camPosY,
--             camPosZ = camPosZ,
--             aimZ = aimZ,
--             camExtZoom = camExtZoom,
--             weaponState = weaponState,
--             aspectRatio = aspectRatio
--         }
--     end
-- end

-- function onReceivePacket(id, bitStream)
--     if id == 203 then
--         local packetId = raknetBitStreamReadInt8(bitStream)
--         local playerId = raknetBitStreamReadInt8(bitStream)
--         local unknown = raknetBitStreamReadInt8(bitStream)
--         local camMode = raknetBitStreamReadInt8(bitStream)
--         local camFrontX = raknetBitStreamReadFloat(bitStream)
--         local camFrontY = raknetBitStreamReadFloat(bitStream)
--         local camFrontZ = raknetBitStreamReadFloat(bitStream)
--         local camPosX = raknetBitStreamReadFloat(bitStream)
--         local camPosY = raknetBitStreamReadFloat(bitStream)
--         local camPosZ = raknetBitStreamReadFloat(bitStream)
--         local aimZ = raknetBitStreamReadFloat(bitStream)
--         local int8 = raknetBitStreamReadInt8(bitStream)
--         local weaponState = math.floor(int8 / 64) % 4
--         local camExtZoom = int8 % 64
--         local aspectRatio = raknetBitStreamReadInt8(bitStream)

--         local data = {
--             camMode = camMode,
--             camFrontX = camFrontX,
--             camFrontY = camFrontY,
--             camFrontZ = camFrontZ,
--             camPosX = camPosX,
--             camPosY = camPosY,
--             camPosZ = camPosZ,
--             aimZ = aimZ,
--             camExtZoom = camExtZoom,
--             weaponState = weaponState,
--             aspectRatio = aspectRatio
--         }
--     end
-- end

-- sampev

function sampev.onAimSync(playerId, data)
    if sampIsPlayerConnected(playerId) then
        local res, char = sampGetCharHandleBySampPlayerId(playerId)
        if res then
            local nick = sampGetPlayerNickname(playerId)
            local hit, realAspect = mod.getRealAspectRatioByWeirdValue(data[aspectRatioKey])

            local playerAimData = {
                camMode = data.camMode,
                camFrontX = data.camFront.x,
                camFrontY = data.camFront.y,
                camFrontZ = data.camFront.z,
                camPosX = data.camPos.x,
                camPosY = data.camPos.y,
                camPosZ = data.camPos.z,
                aimZ = data.aimZ,
                camExtZoom = data.camExtZoom,
                weaponState = data.weaponState,
                aspectRatio = data[aspectRatioKey],

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
                    local p1x, p1y, p1z, p2x, p2y, p2z = mod.processAimLine(playerAimData, aspect)

                    local result, colPoint = processLineOfSight(p1x, p1y, p1z, p2x, p2y, p2z, true, true, true, true,
                        true, true, true, true)
                    if result then
                        if colPoint.entityType == 3 and colPoint.entity == getCharPointer(playerPed) then
                            if playerAimData.weapon == 34 then
                                wraith_passive_triggeredbyped = char
                                needToTriggerAimedPedSniper = true
                            else
                                wraith_passive_triggeredbyped = char
                                needToTriggerAimedPed = true
                            end
                        end
                        if colPoint.entityType == 2 and isCharInAnyCar(playerPed) then
                            if colPoint.entity == getCarPointer(storeCarCharIsInNoSave(playerPed)) then
                                wraith_passive_triggeredbyped = char
                                needToTriggerAimedVehicle = true
                            end
                        end
                    end
                end
            end
        end
    end
end

function sampev.onSendPlayerSync(data)
    if wraith_tactical_active then
        data.position.z = data.position.z - 2.5
        printStyledString(getMessage("tacticalUnderZWarning"), 100, 5)
    end
end

-- audio

function getRandomSoundName()
    local temp = {}
    for k, v in pairs(audioLines) do
        for kk, vv in pairs(v) do
            table.insert(temp, vv)
        end
    end
    local random = temp[math.random(#temp)]
    temp = nil
    return random
end

CURRENT_RANDOM_SOUND = getRandomSoundName()

function playMainSoundNow(path)
    if cfg.audio.enable then
        stopMainSoundNow()
        if doesFileExist(path) then
            mainSoundStream = loadAudioStream(path)
            if cfg.audio.volume ~= 0 and string.find(path, "wraith_voices") then
                setAudioStreamVolume(mainSoundStream, cfg.audio.volume + cfg.audio.quietOffset)
            else
                setAudioStreamVolume(mainSoundStream, cfg.audio.volume)
            end

            setAudioStreamState(mainSoundStream, as_action.PLAY)
        else
            if not cfg.audio.ignoreMissing then
                sampAddChatMessage(getMessage('cantFindResources') .. path, -1)
                sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
            end
        end
    end
end

function stopMainSoundNow()
    if mainSoundStream then
        setAudioStreamState(mainSoundStream, as_action.STOP)
    end
end

-- todo fix dry
function playReserveSoundNow(path)
    if cfg.audio.enable then
        stopReserveSoundNow()
        if doesFileExist(path) then
            reserveSoundStream = loadAudioStream(path)
            if cfg.audio.volume ~= 0 and
                (string.find(path, "wraith_voices") or string.find(path, "tactical.mp3") or
                    string.find(path, "tactical_instant.mp3")) then
                setAudioStreamVolume(reserveSoundStream, cfg.audio.volume + cfg.audio.quietOffset)
            else
                setAudioStreamVolume(reserveSoundStream, cfg.audio.volume)
            end

            setAudioStreamState(reserveSoundStream, as_action.PLAY)
        else
            if not cfg.audio.ignoreMissing then
                sampAddChatMessage(getMessage('cantFindResources') .. path, -1)
                sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
            end
        end
    end
end

function stopReserveSoundNow()
    if reserveSoundStream then
        setAudioStreamState(reserveSoundStream, as_action.STOP)
    end
end

function playRandomFromCategory(category)
    local tempSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\" .. cfg.audio.language .. "\\" ..
        audioLines[category][math.random(#audioLines[category])]

    playMainSoundNow(tempSoundPath)
end

function playTestSound()
    local tempSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\" .. cfg.audio.language .. "\\" ..
        CURRENT_RANDOM_SOUND
    playMainSoundNow(tempSoundPath)
end

function getVolume()
    return {
        radio = 100 / 64 * readMemory(0xBA6798, 1, true),
        SFX = 100 / 64 * readMemory(0xBA6797, 1, true)
    }
end

function checkAudioResources()
    local temp = {
        getWorkingDirectory() .. "\\resource\\wraith\\tactical_instant.mp3",
        getWorkingDirectory() .. "\\resource\\wraith\\tactical.mp3"
    }
    for k, v in pairs(audioLines) do
        for kk, vv in pairs(v) do
            table.insert(temp, getWorkingDirectory() .. "\\resource\\wraith\\" .. cfg.audio.language .. "\\" .. vv)
        end
    end
    local foundIssue = false
    for k, v in pairs(temp) do
        if not doesFileExist(v) then
            temp = nil
            return false
        end
    end
    return true
end

function drawDebugLine(ax, ay, az, bx, by, bz, color1, color2, color3)
    local _1, x1, y1, z1 = convert3DCoordsToScreenEx(ax, ay, az)
    local _2, x2, y2, z2 = convert3DCoordsToScreenEx(bx, by, bz)
    if _1 and _2 and z1 > 0 and z2 > 0 then
        renderDrawPolygon(x1, y1, 10, 10, 10, 0.0, color1)
        renderDrawLine(x1, y1, x2, y2, 2, color2)
        renderDrawPolygon(x2, y2, 10, 10, 10, 0.0, color3)
    end
end

function createTemporaryTracer(tracePed, seconds)
    local start = os.clock()
    while start + seconds > os.clock() do
        wait(0)
        if doesCharExist(tracePed) then
            local x, y, z = getCharCoordinates(playerPed)
            local mX, mY, mZ = getCharCoordinates(tracePed)

            drawDebugLine(x, y, z, mX, mY, mZ, 0xffFF00FF, 0xffFF00FF, 0xffFF00FF)
        end
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
                if pos > 20 then
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

    local function getLastNCharacters(str, n)
        if n >= 0 and n <= #str then
            return string.sub(str, -n)
        else
            return str
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
                        elseif newValue > 100 then
                            newValue = 100
                        end
                        cfg[group][setting] = newValue

                        if funcOnChange then
                            funcOnChange(cfg[group][setting])
                        end

                        sampShowDialog(767, caption, generateStatusString(cfg[group][setting], max), button1)
                    end
                end

                menu[row].title = text .. ": " .. tostring(cfg[group][setting])

                if not ffuncOnEndunc then
                    return true
                else
                    return funcOnEnd(cfg[group][setting], menu, row)
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
            createSimpleToggle("passive", "enable",
                (cfg.passive.enable and "{696969}" or "") .. getMessage("settingPassive"),
                false, function(value, menu, pos)
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
                    createSimpleToggle("passive", "showTempTracer", getMessage("settingPassiveTracer"),
                        not cfg.passive.enable),
                    createSimpleToggle("passive", "printStyledString", getMessage("settingPassiveString"),
                        not cfg.passive.enable),
                    createEmptyLine(),
                    createSimpleSlider("passive", "cooldown",
                        (not cfg.passive.enable and "{696969}" or "") .. getMessage('settingPassiveCooldown'),
                        getMessage('settingPassiveCooldownCaption'), "OK", 6, 100,
                        1, function(v)
                            saveCfg()
                        end),
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
            createSimpleToggle("tactical", "enable",
                (cfg.tactical.enable and "{696969}" or "") .. getMessage("settingTactical"), false,
                function(value, menu, pos)
                    callMenu(pos - 1)
                    return false
                end),

            {
                title = (not cfg.tactical.enable and "{696969}" or "") .. getMessage("tacticalActivationMode") ..
                    (cfg.tactical.enable and ("{ff0000}" .. (cfg.tactical.alt and "LEFT ALT + " or "") .. key.id_to_name(cfg.tactical.key)) or getMessage("tacticalActivationDisabled")),
                submenu = {
                    {
                        title = (not cfg.tactical.enable and "{696969}" or "") ..
                            getMessage("tacticalKeyName") .. key.id_to_name(cfg.tactical.key),
                        onclick = function(menu, row)
                            sampShowDialog(777, getMessage('legacyChangeKeyTitle'), getMessage('legacyChangeKeyText'),
                                getMessage('legacyChangeKeyButton1'), getMessage('legacyChangeKeyButton2'))
                            while sampIsDialogActive(777) do
                                wait(100)
                            end
                            local resultMain, buttonMain, typ = sampHasDialogRespond(777)
                            local isThisBetterThanExtraDependency = true
                            if buttonMain == 1 then
                                while isThisBetterThanExtraDependency do
                                    wait(0)
                                    for i = 1, 200 do
                                        if isKeyDown(i) then
                                            sampAddChatMessage(getMessage('legacyChangeKeySuccess') ..
                                                (cfg.tactical.alt and "LEFT ALT + " or "") ..
                                                key.id_to_name(i), -1)
                                            cfg.tactical.key = i
                                            addOneOffSound(0.0, 0.0, 0.0, 1052)
                                            saveCfg()
                                            isThisBetterThanExtraDependency = false
                                            break
                                        end
                                    end
                                end
                                callMenu(9)
                                return false
                            else
                                return true
                            end
                        end
                    },
                    createSimpleToggle("tactical", "alt", getMessage("settingTacticalAlt"), not cfg.tactical.enable,
                        function()
                            callMenu(9)
                            return false
                        end),
                }
            },
            --tactical settings
            {
                title = (not cfg.tactical.enable and "{696969}" or "") .. getMessage("settingTacticalSection"),
                submenu = {
                    createSimpleToggle("tactical", "instant", getMessage("settingTacticalInstant"),
                        not cfg.tactical.enable),
                    createEmptyLine(),
                    createSimpleSlider("tactical", "cooldown",
                        (not cfg.tactical.enable and "{696969}" or "") .. getMessage('settingTacticalCooldown'),
                        getMessage("settingTacticalCooldownCaption"), "OK", 6, 100,
                        1, function(v)
                            saveCfg()
                        end),
                }
            },
        }
    end
    --audio section
    local function genSectionAudio()
        return {
            (function()
                local basecolor = "{AAAAAA}"
                local str = basecolor .. getMessage("sectionAudio")
                if getVolume().radio == 0 then
                    str = str .. " || {ff0000}" .. getMessage('checkAudioOff') .. basecolor
                else
                    if radio_were_disabled then
                        str = str .. " || {ff0000}" .. getMessage('checkAudioOffNeedReboot') .. basecolor
                    end
                    str = str .. " || {00ff00}" .. getMessage("checkAudioOn") .. basecolor
                end
                if checkAudioResources() then
                    str = str .. " || {00ff00}" .. getMessage("checkResourcesYes") .. basecolor
                else
                    str = str .. " || {ff0000}" .. getMessage("checkResourcesNo") .. basecolor
                end

                return {
                    title = str
                }
            end)(),

            createSimpleToggle("audio", "enable", getMessage("settingAudioEnable"), false),
            createSimpleToggle("audio", "ignoreMissing", getMessage('settingIgnoreMissing'), false),

            (function()
                local langId = 1
                for k, v in pairs(audioLanguages) do
                    if v == cfg.audio.language then
                        langId = k
                    end
                end
                local submenu = {}

                for k, v in pairs(audioLanguages) do
                    table.insert(submenu, {
                        title = i18n.audioLangTable[cfg.options.language][k],
                        onclick = function(menu, row)
                            cfg.audio.language = audioLanguages[row]
                            playTestSound()
                            saveCfg()
                            callMenu()
                        end
                    })
                end

                return {
                    title = getMessage("lang") .. i18n.audioLangTable[cfg.options.language][langId],
                    submenu =
                        submenu
                }
            end)(),

            createSimpleSlider("audio", "volume", getMessage('settingVolume'),
                getMessage("settingVolumeCaption"), "OK", 0, 100,
                1, function(v)
                    playTestSound()
                    saveCfg()
                end),

            createSimpleSlider("audio", "quietOffset", getMessage('settingVolumeQuietOffset'),
                getMessage("settingVolumeQuietOffsetCaption"), "OK", 0, 100,
                1, function(v)
                    stopMainSoundNow()
                    stopReserveSoundNow()
                    if math.random(1, 10) % 2 == 0 then
                        playRandomFromCategory('aiming')
                    else
                        -- fix
                        playReserveSoundNow(getWorkingDirectory() .. "\\resource\\wraith\\tactical_instant.mp3")
                    end
                    saveCfg()
                end),

            {
                title = getMessage('randomSound') .. getLastNCharacters(CURRENT_RANDOM_SOUND, 30),
                onclick = function(menu, row)
                    CURRENT_RANDOM_SOUND = getRandomSoundName()
                    playTestSound()
                    menu[row].title = getMessage('randomSound') .. getLastNCharacters(CURRENT_RANDOM_SOUND, 31)
                    return true
                end
            },

            {
                title = "PLAY",
                onclick = function(menu, row)
                    playTestSound()
                    return true
                end
            }
        }
    end
    -- settings section
    local function genSectionSettings()
        return { {
            title = getMessage("sectionSettings")
        },
            createSimpleToggle("options", "welcomeMessage", getMessage('settingWelcomeMessage'), false),
            createSimpleToggle('audio', 'noRadio', getMessage('settingNoRadio'), false, function(value)
                if value then
                    writeMemory(0x4EB9A0, 3, 1218, true)
                else
                    writeMemory(0x4EB9A0, 3, 15305557, true)
                end
                return true
            end) }
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

    mergeMenu(mod_submenus_sa, genSectionAudio())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionSettings())
    mergeMenu(mod_submenus_sa, { createEmptyLine() })

    mergeMenu(mod_submenus_sa, genSectionMisc())

    submenus_show(mod_submenus_sa,
        "{348cb2}/wraith v." .. thisScript().version .. " || BLASTHACK SC23 2nd PLACE", getMessage("button1"),
        getMessage("button2"), getMessage("button3"),
        pos)
end
