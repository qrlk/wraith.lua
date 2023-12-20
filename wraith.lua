require 'lib.moonloader'

script_name("wraith.lua")
script_author("qrlk")
script_description("wraith passive + tactical")
-- made for https://www.blast.hk/threads/193650/
script_url("https://github.com/qrlk/wraith.lua")
script_version("20.12.2023-rc1")

-- https://github.com/qrlk/qrlk.lua.moonloader
local enable_sentry = true -- false to disable error reports to sentry.io
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
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
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
local key = require 'vkeys'

local font_flag = require('moonloader').font_flag
local as_action = require('moonloader').audiostream_state
local my_font = renderCreateFont('Verdana', 12, font_flag.BOLD + font_flag.SHADOW)

local imgui = require 'imgui'
local memory = require("memory")

local encoding = require "encoding"
encoding.default = 'CP1251'
local u8 = encoding.UTF8
--

-- cringe internalization solution

local i18n = {
    data = {
        welcomeMessage = {
            en = "{348cb2}wraith.lua v" .. thisScript().version ..
                " activated! {7ef3fa}/wraith - menu. {348cb2}</> by qrlk for {7ef3fa}BLASTHACK.NET{348cb2} SC23 competition.",
            ru = "{348cb2}wraith.lua v" .. thisScript().version ..
                " активирован! {7ef3fa}/wraith - menu. {348cb2}Автор: qrlk специально для {7ef3fa}BLASTHACK.NET{348cb2} SC23."
        },

        radioDisabledWarning = {
            en = "{348cb2}wraith.lua cannot play sounds. {7ef3fa}Increase the radio volume in the settings and restart the game.",
            ru = "{348cb2}wraith.lua не может воспроизводить звуки. {7ef3fa}Увеличьте громкость радио в настройках и перезайдите в игру."
        },

        radioDisabledWarningImgui = {
            en = "Increase the radio volume in settings and restart the game.",
            ru = "Увеличьте громкость радио в настройках и перезайдите в игру."
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
            en = "English",
            ru = "Russian"
        },

        sectionAbout = {
            en = "About",
            ru = "Описание"
        },
        description = {
            en = "wraith.lua is a cheat for SA:MP that implements some abilities of Wraith from Apex Legends.\n\nThis script was written by qrlk for the BLASTHACK community and the SC23 competition.",
            ru = "wraith.lua - это чит, который переносит некоторые способности персонажа Wraith из игры Apex Legends в SA:MP.\n\nАвтор: qrlk. Скрипт написан специально для сообщества BLASTHACK (SC23)."
        },

        moreAboutScript = {
            en = "More about wraith.lua",
            ru = "Подробнее о wraith.lua"
        },

        moreAboutSC = {
            en = "More about SC23",
            ru = "Подробнее о SC23"
        },

        sectionTweaks = {
            en = "Settings",
            ru = "Общие настройки"
        },
        settingWelcomeMessage = {
            en = "Show welcome message",
            ru = "Показывать вступительное сообщение"
        },
        tooltipSettingWelcomeMessage = {
            en = "If enabled, a welcome message will appear in the chat when the script is launched.",
            ru = "Если включено, при запуске скрипта в чате появится приветственное сообщение."
        },

        sectionAudio = {
            en = "Audio",
            ru = "Аудио"
        },

        settingNoRadio = {
            en = "Block radio selection in vehicles",
            ru = "Блокировать выбор радио в машине"
        },
        tooltipSettingNoRadio = {
            en = "Turns off the radio in the car if it bothers you.\nAfter changing the setting, you need to restart the game.",
            ru = "Выключает радио в машине, если оно вам мешает.\nПосле изменения настройки нужен перезапуск игры."
        },

        settingIgnoreMissing = {
            en = "Ignore missing sounds",
            ru = "Игнорировать ненайденные звуки"
        },
        tooltipSettingIgnoreMissing = {
            en = "Enable this setting to remove the chat warning that audio was not found when attempting to play.",
            ru = "Включите эту настройку, чтобы убрать предупреждение в чате, что звук при попытке воспроизведения не был найден."
        },

        settingAudioLanguage = {
            en = "Audio language",
            ru = "Язык аудио"
        },
        settingVolume = {
            en = "Volume",
            ru = "Громкость"
        },

        settingVolumeQuietOffset = {
            en = "Increased volume for quiet sounds",
            ru = "Увеличение громкости для тихих звуков"
        },

        randomSound = {
            en = "Random sound: ",
            ru = "Случайная реплика: "
        },

        sectionPassive = {
            en = "Passive ability - Voices from the Void",
            ru = "Пассивная способность - Голоса из Пустоты"
        },
        settingPassiveEnable = {
            en = "Enable passive ability",
            ru = "Включить пассивную способность"
        },
        tooltipSettingPassiveEnable = {
            en = "A voice warns you when danger approaches.\nAs far as you can tell, it's on your side.",
            ru = "Некий голос всегда предупреждает вас об опасности.\nСудя по всему, этот голос на вашей стороне."
        },
        settingPassiveTracer = {
            en = "Show temporary tracer to enemy when ability is triggered",
            ru = "Показывать временный трасер до противника при активации"
        },
        tooltipSettingPassiveTracer = {
            en = "",
            ru = ""
        },
        settingPassiveString = {
            en = "Show gametext warning when ability is triggered",
            ru = "Показывать игровую строку-предупреждение при триггере голоса из пустоты"
        },
        tooltipSettingPassiveString = {
            en = "",
            ru = ""
        },

        settingPassiveCooldown = {
            en = "passive ability cooldown (in seconds)",
            ru = "кулдаун пассивной способности (в сек.)"
        },

        tacticalUnderZWarning = {
            en = 'YOU ARE UNDER GROUND!!!',
            ru = 'VI POD ZEMLEY!!!'
        },

        sectionTactical = {
            en = "Tactical ability - Into the Void",
            ru = "Тактическая способность - В Пустоту"
        },

        settingTacticalEnable = {
            en = "Enable tactical ability",
            ru = "Включить тактическую способность"
        },
        tooltipSettingTacticalEnable = {
            en = "Reposition quickly through the safety of void space, avoiding all damage.",
            ru = "Быстро перемещает вас сквозь Пустоту, позволяя избежать урона."
        },

        settingTacticalAlt = {
            en = "Need to press left alt + the configured button to trigger",
            ru = "Нужно нажать левый альт + заданную кнопку для активации"
        },
        tooltipSettingTacticalAlt = {
            en = "If active, to trigger, in addition to the main key, you will need to hold the left alt.",
            ru = "Если активно, для активации помимо основной клавиши нужно будет держать левый альт."
        },

        settingTacticalInstant = {
            en = "Remove delay before activation",
            ru = "Убрать задержку перед активацией"
        },
        tooltipSettingTacticalInstant = {
            en = "If active, there will be no delay before activation - but you will not be able to cancel the ability's activation.",
            ru = "Если активно, задержки перед активацией не будет - но вы не сможете отменить запуск способности."
        },

        tacticalCheatWarning = {
            en = "Attention! This is a cheat! Turn the ability off if you don't know what you're doing.",
            ru = "Внимание! Это чит! Отключите способность, если не понимаете что делаете."
        },
        tacticalHotkey = {
            en = "Hotkey to trigger: ",
            ru = "Кнопка активации: "
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
            en = "ability cooldown (in seconds)",
            ru = "кулдаун способности (в сек.)"
        },

        sectionDebug = {
            en = "Debug (on/off debug)",
            ru = "Debug (вкл/выкл отладки)"
        },
        settingDebug = {
            en = "Enable debug",
            ru = "Включить отладку"
        },
        tooltipSettingDebug = {
            en = "Gives access to debugging features. Playing with debugging enabled is not recommended;\ndebugging tools are not optimized for performance.",
            ru = "Даёт доступ к отладочным функциям. Играть с включенной отладкой не рекомендуются,\nинструменты отладки не оптимизированы по производительности."
        },

        settingDebugNeedAimLines = {
            en = "Activate aimSync recording for all players",
            ru = "Активировать функционал записи данных прицела у всех игроков"
        },
        tooltipSettingDebugNeedAimLines = {
            en = "",
            ru = ""
        },

        settingDebugNeedAimLinesFull = {
            en = "Render of the full aimline for all players",
            ru = "Рендер полной линии прицела у всех игроков"
        },
        tooltipSettingDebugNeedAimLinesFull = {
            en = "",
            ru = ""
        },

        settingDebugNeedAimLinesLOS = {
            en = "Render aimline to collision for all players",
            ru = "Рендер линии прицела до столкновения у всех игроков"
        },
        tooltipSettingDebugNeedAimLinesLOS = {
            en = "",
            ru = ""
        },

        settingDebugNeed3dtext = {
            en = "Create 3D text on peds with their GTA aspect ratio",
            ru = "Создавать 3д текст на игроках с соотношением сторон их гта"
        },
        tooltipSettingDebugNeed3dtext = {
            en = "",
            ru = ""
        },

        settingDebugNeedAimLine = {
            en = "Activate aimSync recording for you",
            ru = "Активировать функционал записи данных прицела у вашего персонажа"
        },
        tooltipSettingDebugNeedAimLine = {
            en = "",
            ru = ""
        },

        settingDebugNeedAimLineFull = {
            en = "Render your character's full aimline",
            ru = "Рендер полной линии прицела у вашего персонажа"
        },
        tooltipSettingDebugNeedAimLineFull = {
            en = "",
            ru = ""
        },

        settingDebugNeedAimLineLOS = {
            en = "Render the aimline to the collision for your character",
            ru = "Рендер линии прицела до столкновения у вашего персонажа"
        },
        tooltipSettingDebugNeedAimLineLOS = {
            en = "",
            ru = ""
        },

        settingDebugNeedDrawAngles = {
            en = "Render current angle",
            ru = "Рендерит текущие углы"
        },
        tooltipSettingDebugNeedDrawAngles = {
            en = "",
            ru = ""
        },

        settingNeedToTweakAngles = {
            en = "Need to tweak angles",
            ru = "Нужно изменять углы"
        },
        tooltipSettingNeedToTweakAngles = {
            en = "Activates changing weapon angles via alt + keyboard arrows",
            ru = "Активирует изменение углов оружия через alt + стрелки клавиатуры"
        },

        settingNeedToSaveAnglesIni = {
            en = "Save angles",
            ru = "Сохранять измененные углы"
        },
        tooltipSettingNeedToSaveAnglesIni = {
            en = "don't touch pls",
            ru = "не трогайте"
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
        }

    },
    audioLangTable = {
        en = {'English', 'Russian', 'French', 'Italian', 'German', 'Spanish', 'Japanese', 'Korean', 'Polish', 'Chinese'},
        ru = {u8 'Английский', u8 'Русский', u8 'Французский', u8 'Итальянский',
              u8 'Немецкий', u8 'Испанский', u8 'Японский', u8 'Корейский',
              u8 'Польский', u8 'Китайский'}
    }
}

--
local audioLanguages = {'en', 'ru', 'fr', 'it', 'de', 'es', 'ja', 'ko', 'pl', 'zh'}
local audioLines = {
    aiming = {"diag_mp_wraith_voices_seesPlayer_urgent_01_01_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_01_02_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_02_01_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_02_02_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_02_03_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_03_01_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_03_02_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_04_01_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_04_02_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_05_01_1p.mp3",
              "diag_mp_wraith_voices_seesPlayer_urgent_05_02_1p.mp3"},
    lol = {"diag_mp_wraith_bc_locationAWH_01_01_1p.mp3", "diag_mp_wraith_bc_locationAWH_01_02_1p.mp3"},
    no = {"diag_mp_wraith_ping_no_01_01_1p.mp3", "diag_mp_wraith_ping_no_01_02_1p.mp3",
          "diag_mp_wraith_ping_no_01_03_1p.mp3", "diag_mp_wraith_ping_no_02_01_1p.mp3",
          "diag_mp_wraith_ping_no_02_02_1p.mp3", "diag_mp_wraith_ping_no_02_03_1p.mp3"},
    notReady = {"diag_mp_wraith_ping_ultUpdate_notReady_calm_01_01_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_calm_01_02_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_01_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_02_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_calm_02_03_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_01_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_02_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_01_03_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_01_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_02_1p.mp3",
                "diag_mp_wraith_ping_ultUpdate_notReady_urgent_02_03_1p.mp3"},
    isReady = {"diag_mp_wraith_ping_ultUpdate_isReady_calm_01_01_1p.mp3",
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
               "diag_mp_wraith_ping_ultUpdate_isReady_urgent_02_03_1p.mp3"},
    sniper = {"diag_mp_wraith_voices_sniper_urgent_01_01_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_01_02_1p.mp3",
              "diag_mp_wraith_voices_sniper_urgent_01_03_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_02_01_1p.mp3",
              "diag_mp_wraith_voices_sniper_urgent_02_02_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_02_03_1p.mp3",
              "diag_mp_wraith_voices_sniper_urgent_03_01_1p.mp3", "diag_mp_wraith_voices_sniper_urgent_03_02_1p.mp3",
              "diag_mp_wraith_voices_sniper_urgent_03_03_1p.mp3"},
    tactical = {"diag_mp_wraith_bc_tactical_01_01_1p.mp3", "diag_mp_wraith_bc_tactical_01_02_1p.mp3",
                "diag_mp_wraith_bc_tactical_01_03_1p.mp3", "diag_mp_wraith_bc_tactical_02_01_1p.mp3",
                "diag_mp_wraith_bc_tactical_02_02_1p.mp3", "diag_mp_wraith_bc_tactical_02_03_1p.mp3",
                "diag_mp_wraith_bc_tactical_03_01_1p.mp3", "diag_mp_wraith_bc_tactical_03_02_1p.mp3",
                "diag_mp_wraith_bc_tactical_03_03_1p.mp3", "diag_mp_wraith_bc_tactical_04_01_1p.mp3",
                "diag_mp_wraith_bc_tactical_04_02_1p.mp3", "diag_mp_wraith_bc_tactical_04_03_1p.mp3"},
    vehicle = {"diag_mp_wraith_voices_hostiles_urgent_01_01_1p.mp3",
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
               "diag_mp_wraith_voices_hostiles_urgent_05_02_1p.mp3"}
}

local cfg = inicfg.load({
    options = {
        welcomeMessage = true,
        language = "ru",
        debug = false,
        debugNeedAimLines = true,
        debugNeedAimLinesFull = true,
        debugNeedAimLinesLOS = true,
        debugNeed3dtext = true,
        debugNeedAimLine = true,
        debugNeedAimLineFull = true,
        debugNeedAimLineLOS = true,
        debugNeedToDrawAngles = false,
        debugNeedToTweakAngles = false,
        debugNeedToSaveAngles = false,
    },
    audio = {
        language = "ru",
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

local main_window_state = imgui.ImBool(false)
-- local main_window_state = imgui.ImBool(true)

local welcomeMessage = imgui.ImBool(cfg.options.welcomeMessage)

--
local DEBUG = imgui.ImBool(cfg.options.debug)

local DEBUG_NEED_AIMLINES = imgui.ImBool(cfg.options.debugNeedAimLines)
local DEBUG_NEED_AIMLINES_FULL = imgui.ImBool(cfg.options.debugNeedAimLinesFull)
local DEBUG_NEED_AIMLINES_LOS = imgui.ImBool(cfg.options.debugNeedAimLinesLOS)
local DEBUG_NEED_3DTEXT = imgui.ImBool(cfg.options.debugNeed3dtext)

local DEBUG_NEED_AIMLINE = imgui.ImBool(cfg.options.debugNeedAimLine)
local DEBUG_NEED_AIMLINE_FULL = imgui.ImBool(cfg.options.debugNeedAimLineFull)
local DEBUG_NEED_AIMLINE_LOS = imgui.ImBool(cfg.options.debugNeedAimLineLOS)

local DEBUG_NEED_DRAW_ANGLES = imgui.ImBool(cfg.options.debugNeedToDrawAngles)
local DEBUG_NEED_TO_TWEAK_ANGLES = imgui.ImBool(cfg.options.debugNeedToTweakAngles)
local DEBUG_NEED_TO_SAVE_ANGLES_INI = imgui.ImBool(cfg.options.debugNeedToSaveAngles)

local NO_RADIO = imgui.ImBool(cfg.audio.noRadio)
local AUDIO_VOLUME = imgui.ImInt(cfg.audio.volume)
local AUDIO_VOLUME_QUIET_OFFSET = imgui.ImInt(cfg.audio.quietOffset)

local AUDIO_IGNORE_MISSING_RESOURCES = imgui.ImBool(cfg.audio.ignoreMissing)
local AUDIO_LANGUAGE = imgui.ImInt(0)
for k, v in pairs(audioLanguages) do
    if v == cfg.audio.language then
        AUDIO_LANGUAGE.v = k - 1
    end
end

local PASSIVE_ENABLE = imgui.ImBool(cfg.passive.enable)
local PASSIVE_TRACER = imgui.ImBool(cfg.passive.showTempTracer)
local PASSIVE_STRING = imgui.ImBool(cfg.passive.printStyledString)
local PASSIVE_COOLDOWN = imgui.ImInt(cfg.passive.cooldown)

local TACTICAL_ENABLE = imgui.ImBool(cfg.tactical.enable)
local TACTICAL_COOLDOWN = imgui.ImInt(cfg.tactical.cooldown)
local TACTICAL_LMENU = imgui.ImBool(cfg.tactical.alt)
local TACTICAL_INSTANT = imgui.ImBool(cfg.tactical.instant)

local DEBUG_NEED_TO_EMULATE_CAMERA = false
local DEBUG_NEED_TO_EMULATE_CAMERA_BY_ID = 3

local DEBUG_ENABLE_WEATHER_BROWSE = false
--

local debug3dText = {}

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

local playersAimData = {}
local playerPedAimData = false

local requestToUnload = false

-- trying to ulitize aspectRatio property from aimSync

local aspectRatios = {
    [63] = "5:4", -- 1,25
    [85] = "4:3", -- 1,333333333333333
    [98] = "43:18", -- 2,388888888888889
    [127] = "3:2", -- 1,5
    [143] = "25:16", -- 1,5625
    [153] = "16:10", -- 1,6
    [169] = "5:3", -- 1,666666666666667
    -- [196] = "16:9 (alt)", -- 1,771084337349398
    [198] = "16:9" -- 1,777777777777778
}

local approximateAspectRatio = {{
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
}}

function getRealAspectRatioByWeirdValue(aspectRatio)
    local hit = false
    if aspectRatios[aspectRatio] ~= nil then
        hit = true
        return hit, aspectRatios[aspectRatio]
    end
    for k, v in pairs(approximateAspectRatio) do
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

-- thi debug ini is not saved by default and formally loads for debugging purposes only
-- if the values change in possible updates, the name of the .ini file will be changed

local angelsIniFileName = "wraith-debug-20231219"
local anglesPerAspectRatio = inicfg.load({
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
}, angelsIniFileName)

local mainSoundStream = loadAudioStream()
local reserveSoundStream = loadAudioStream()

function getCurrentWeaponAngle(aspect, weapon)
    if aspect == "unknown" then
        aspect = "4:3"
    end

    if (weapon >= 22 and weapon <= 29) or weapon == 32 then
        return {anglesPerAspectRatio[aspect].curxy, anglesPerAspectRatio[aspect].curz}
    elseif weapon == 30 or weapon == 31 then
        return {anglesPerAspectRatio[aspect].curARxy, anglesPerAspectRatio[aspect].curARz}
    elseif weapon == 33 then
        return {anglesPerAspectRatio[aspect].curRFxy, anglesPerAspectRatio[aspect].curRFz}
    end

    return {0.0, 0.0}
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
                if PASSIVE_STRING.v then
                    printStyledString(string.format("AIMED by %s [%s] (%sm)", nick, id, dist), 5000, 5)
                end
            elseif typ == "sniper" then
                playRandomFromCategory('sniper')
                if PASSIVE_STRING.v then
                    printStyledString(string.format("SNIPER!!! %s [%s] (%sm)", nick, id, dist), 3000, 5)
                end
            elseif typ == "vehicle" then
                playRandomFromCategory('vehicle')
                if PASSIVE_STRING.v then
                    printStyledString(string.format("DANGER!!! %s [%s] (%sm)", nick, id, dist), 3000, 5)
                end
            end

            if PASSIVE_TRACER.v and enemyPed then
                table.insert(tempThreads, lua_thread.create(createTemporaryTracer, enemyPed, 5))
            end
        end
    end
end

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
local CURRENT_RANDOM_SOUND = getRandomSoundName()


function playMainSoundNow(path)
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
        if not AUDIO_IGNORE_MISSING_RESOURCES.v then
            sampAddChatMessage(getMessage('cantFindResources') .. path, -1)
            sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
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
        if not AUDIO_IGNORE_MISSING_RESOURCES.v then
            sampAddChatMessage(getMessage('cantFindResources') .. path, -1)
            sampAddChatMessage(getMessage('pleaseDownloadResources'), -1)
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

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
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

    -- sc23

    if DEBUG_ENABLE_WEATHER_BROWSE then
        local weather = 478
        local hour = 14
        while DEBUG_ENABLE_WEATHER_BROWSE do
            wait(0)
            renderFontDrawText(my_font, string.format('W: %s || H: %s', weather, hour), 100, 400, 0xFFFFFFFF)

            forceWeatherNow(weather)
            setTimeOfDay(hour, 0)

            if true and (isKeyDown(0x25) or isKeyDown(0x26) or isKeyDown(0x27) or isKeyDown(0x28)) then
                if isKeyDown(0x25) then
                    -- left
                    print(string.format('left'), 1, 1)
                    weather = weather - 1
                elseif isKeyDown(0x26) then
                    -- up
                    print(string.format('up'), 1, 1)
                    hour = hour + 1
                elseif isKeyDown(0x27) then
                    -- right
                    print(string.format('right'), 1, 1)
                    weather = weather + 1
                elseif isKeyDown(0x28) then
                    -- down
                    print(string.format('down'), 1, 1)
                    hour = hour - 1
                end

                wait(100)
            end
        end
    end

    local phasingSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\tactical.mp3"
    local phasingInstantSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\tactical_instant.mp3"

    sampRegisterChatCommand('wraith', function()
        main_window_state.v = not main_window_state.v
    end)

    apply_custom_style()

    while sampGetCurrentServerName() == "SA-MP" do
        wait(500)
    end
    if cfg.options.welcomeMessage then
        sampAddChatMessage(getMessage('welcomeMessage'), 0x7ef3fa)

        if getVolume().radio == 0 and cfg.audio.volume ~= 0 then
            sampAddChatMessage(getMessage('radioDisabledWarning'), 0x7ef3fa)
        end

        if TACTICAL_ENABLE.v then
            playRandomFromCategory('isReady')
        end
    end

    if cfg.audio.noRadio then
        memory.copy(0x4EB9A0, memory.strptr("\xC2\x04\x00"), 3, true)
    end

    while true do
        wait(0)

        if TACTICAL_ENABLE.v and ((isKeyDown(0xA4) or not TACTICAL_LMENU.v) and wasKeyPressed(cfg.tactical.key)) then
            if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
                if isCharOnFoot(playerPed) and not isCharDead(playerPed) then
                    if os.clock() - TACTICAL_COOLDOWN.v > wraith_tactical_lastused then
                        table.insert(tempThreads, lua_thread.create(function()
                            if TACTICAL_INSTANT.v then
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
                            if not TACTICAL_INSTANT.v and isKeyDown(cfg.tactical.key) then
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
                        while os.clock() - start_wait < (TACTICAL_INSTANT.v and 4.5 or 6.5) do
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
                        local left = math.floor(TACTICAL_COOLDOWN.v - (os.clock() - wraith_tactical_lastused))
                        printStringNow(string.format('%sc', left), 3000)
                    end
                end
            end
        end

        if DEBUG.v and (DEBUG_NEED_AIMLINES.v or DEBUG_NEED_3DTEXT.v) then
            for nick, data in pairs(playersAimData) do
                if sampIsPlayerConnected(data.playerId) then
                    local result, ped = sampGetCharHandleBySampPlayerId(data.playerId)
                    if result and sampGetPlayerNickname(data.playerId) == nick then
                        if DEBUG_NEED_AIMLINES.v and data.camMode ~= 4 then
                            local aspects = {data.realAspect}

                            if data.realAspect == "16:9" then
                                aspects[2] = "16:9noWSF"
                            end

                            for k, aspect in pairs(aspects) do
                                local p1x, p1y, p1z, p2x, p2y, p2z = processAimLine(data, aspect)

                                if DEBUG_NEED_AIMLINES_FULL.v then
                                    drawDebugLine(p1x, p1y, p1z, p2x, p2y, p2z, 0xff00ffff, 0xffffffff, 0xff348cb2)
                                end

                                if DEBUG_NEED_AIMLINES_LOS.v then
                                    local result, colPoint =
                                        processLineOfSight(p1x, p1y, p1z, p2x, p2y, p2z, true, true, true, true, true,
                                            true, true, true)
                                    if result then
                                        drawDebugLine(p1x, p1y, p1z, colPoint.pos[1], colPoint.pos[2], colPoint.pos[3],
                                            0xff004cff, 0xff004cff, 0xff004cff)
                                    end
                                end
                            end
                        end

                        if DEBUG.v and DEBUG_NEED_3DTEXT.v and debug3dText[nick] == nil then
                            local text = string.format("%s, %s, hit: %s", os.clock(), data.realAspect,
                                data.realAspectHit)
                            local sampTextId = sampCreate3dText(text, 0xFFFFFFFF, 0.0, 0.0, 0.02, 10.0, false,
                                data.playerId, -1)
                            debug3dText[nick] = sampTextId
                        end
                    else
                        playersAimData[nick] = nil
                        if debug3dText[nick] ~= nil then
                            sampDestroy3dText(debug3dText[nick])
                            debug3dText[nick] = nil
                        end
                    end
                else
                    playersAimData[nick] = nil
                    if debug3dText[nick] ~= nil then
                        sampDestroy3dText(debug3dText[nick])
                        debug3dText[nick] = nil
                    end
                end
            end
        end

        if DEBUG.v and DEBUG_NEED_AIMLINE.v and playerPedAimData then
            if DEBUG.v and DEBUG_NEED_TO_TWEAK_ANGLES.v then
                processDebugOffset(playerPedAimData.realAspect, playerPedAimData.weapon)
            end

            if DEBUG_NEED_AIMLINE.v then
                local aspects = {playerPedAimData.realAspect}

                if playerPedAimData.realAspect == "16:9" then
                    aspects[2] = "16:9noWSF"
                end

                for k, aspect in pairs(aspects) do
                    local p1x, p1y, p1z, p2x, p2y, p2z = processAimLine(playerPedAimData, aspect)

                    if DEBUG_NEED_AIMLINE_FULL.v then
                        drawDebugLine(p1x, p1y, p1z, p2x, p2y, p2z, 0xff00ffff, 0xffffffff, 0xff348cb2)
                    end

                    if DEBUG_NEED_AIMLINE_LOS.v then
                        local result, colPoint = processLineOfSight(p1x, p1y, p1z, p2x, p2y, p2z, true, true, true,
                            true, true, true, true, true)
                        if result then
                            drawDebugLine(p1x, p1y, p1z, colPoint.pos[1], colPoint.pos[2], colPoint.pos[3], 0xff004cff,
                                0xff004cff, 0xff004cff)
                        end
                    end
                end
            end
        end

        -- TODO: rework wraith_passive_triggeredbyped logic
        if needToTriggerAimedPed then
            needToTriggerAimedPed = false
            if PASSIVE_ENABLE.v and os.clock() - PASSIVE_COOLDOWN.v > wraith_passive_lastused then
                triggerPassive('aiming', wraith_passive_triggeredbyped)
            end
        end

        if needToTriggerAimedPedSniper then
            needToTriggerAimedPedSniper = false
            if PASSIVE_ENABLE.v and os.clock() - PASSIVE_COOLDOWN.v > wraith_passive_lastused then
                triggerPassive('sniper', wraith_passive_triggeredbyped)
            end
        end

        if needToTriggerAimedVehicle then
            needToTriggerAimedVehicle = false
            if PASSIVE_ENABLE.v and os.clock() - PASSIVE_COOLDOWN.v > wraith_passive_lastused then
                triggerPassive('vehicle', wraith_passive_triggeredbyped)
            end
        end

        imgui.Process = main_window_state.v

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

function processAimLine(data, aspect)
    -- data.weapon
    local currentWeaponAngle = getCurrentWeaponAngle(aspect, data.weapon)

    if DEBUG.v and DEBUG_NEED_DRAW_ANGLES.v then
        renderFontDrawText(my_font,
            string.format('a: %s || w: %s || curxy: %s || curz: %s', aspect, data.weapon, currentWeaponAngle[1],
                currentWeaponAngle[2]), 100, 400, 0xFFFFFFFF)
    end

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

-- sampev

function sampev.onSendAimSync(data)
    if DEBUG.v and DEBUG_NEED_AIMLINE.v and data.camMode ~= 4 and data.camMode ~= 18 then
        local hit, realAspect = getRealAspectRatioByWeirdValue(data.aspectRatio)

        playerPedAimData = {
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
            aspectRatio = data.aspectRatio,

            realAspectHit = hit,
            realAspect = realAspect,
            weapon = getCurrentCharWeapon(playerPed)
        }
    end
end

function sampev.onAimSync(playerId, data)
    if sampIsPlayerConnected(playerId) then
        local res, char = sampGetCharHandleBySampPlayerId(playerId)
        if res then
            local nick = sampGetPlayerNickname(playerId)
            local hit, realAspect = getRealAspectRatioByWeirdValue(data.aspectRatio)

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
                aspectRatio = data.aspectRatio,

                playerId = playerId,
                realAspectHit = hit,
                realAspect = realAspect,
                weapon = getCurrentCharWeapon(char)
            } 

            if DEBUG.v and (DEBUG_NEED_AIMLINES.v or DEBUG_NEED_3DTEXT.v) then
                playersAimData[nick] = playerAimData
            end

            --TODO 27 when cant see ped?
            if (data.camMode ~= 4 and (readMemory(getCharPointer(char) + 0x528, 1, false) == 19 or readMemory(getCharPointer(char) + 0x528, 1, false) == 27)) or data.camMode == 55 then
                local aspects = {playerAimData.realAspect}

                if playerAimData.realAspect == "16:9" then
                    aspects[2] = "16:9noWSF"
                end

                for k, aspect in pairs(aspects) do
                    local p1x, p1y, p1z, p2x, p2y, p2z = processAimLine(playerAimData, aspect)

                    local result, colPoint = processLineOfSight(p1x, p1y, p1z, p2x, p2y, p2z, true, true, true, true,
                        true, true, true, true)
                        print(result,colPoint)
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

            if DEBUG.v and DEBUG_NEED_TO_EMULATE_CAMERA then
                local _, lId = sampGetPlayerIdByCharHandle(playerPed)
                if _ and lId == DEBUG_NEED_TO_EMULATE_CAMERA_BY_ID then
                    local p1x, p1y, p1z = data.camPos.x, data.camPos.y, data.camPos.z
                    local p2x, p2y, p2z = data.camPos.x + data.camFront.x * 5, data.camPos.y + data.camFront.y * 5,
                        data.camPos.z + data.camFront.z * 5
                    camPos(p1x, p1y, p1z, 0.0, 0.0, 0.0)
                    ponCameraPoint(p2x, p2y, p2z, 2)
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

-- imgui menu

function createImguiCheckbox(imBool, group, key, keyDescription, keyTooltip)
    if imgui.Checkbox(string.format("##%s", group .. key), imBool) then
        cfg[group][key] = imBool.v
        saveCfg()
    end
    imgui.SameLine()
    if imBool.v then
        imgui.Text(u8:encode(getMessage(keyDescription)))
    else
        imgui.TextDisabled(u8:encode(getMessage(keyDescription)))
    end
    if keyTooltip and getMessage(keyTooltip) ~= "" then
        imgui.SameLine()
        imgui.TextDisabled("(?)")
        if imgui.IsItemHovered() then
            imgui.SetTooltip(u8:encode(getMessage(keyTooltip)))
        end
    end
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
    print(shell32.ShellExecuteA(nil, 'open', link, nil, nil, 1))
end

function playTestSound()
    local tempSoundPath = getWorkingDirectory() .. "\\resource\\wraith\\" .. cfg.audio.language .. "\\" ..
                              CURRENT_RANDOM_SOUND
    playMainSoundNow(tempSoundPath)
end

function getVolume()
    return {
        radio = 100 / 64 * require('memory').getint8(0xBA6798, true),
        SFX = 100 / 64 * require('memory').getint8(0xBA6797, true)
    }
    -- можно использовать return memory.getint8(0xBA6798, true), но там максимальное число 64, то есть если радио на фулл то вернет 64
end

function imgui.OnDrawFrame()
    if main_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(250, 250), imgui.Cond.FirstUseEver)
        imgui.Begin('/wraith by qrlk', main_window_state, imgui.WindowFlags.NoCollapse)

        imgui.Text(u8:encode(getMessage('sectionTweaks')))
        createImguiCheckbox(welcomeMessage, 'options', 'welcomeMessage', 'settingWelcomeMessage',
            'tooltipSettingWelcomeMessage')
        if imgui.Button(u8:encode(getMessage('changeLang'))) then
            if cfg.options.language == "en" then
                cfg.options.language = "ru"
            else
                cfg.options.language = "en"
            end
            saveCfg()
            printStringNow(getMessage('langChanged'), 1000)
        end

        if imgui.Button(u8:encode(getMessage('unloadScript'))) then
            printStringNow('wraith.lua terminated :c', 1000)
            main_window_state.v = false
            requestToUnload = true
        end

        imgui.NewLine()

        imgui.Text(u8:encode("Описание"))
        imgui.TextWrapped(u8:encode(getMessage('description')))

        if imgui.Button(u8:encode(getMessage('moreAboutScript'))) then
            openLink("https://github.com/qrlk/wraith.lua")
        end

        if imgui.Button(u8:encode(getMessage('moreAboutSC'))) then
            openLink("https://www.blast.hk/threads/193650/")
        end

        imgui.NewLine()

        imgui.Text(u8:encode(getMessage('sectionPassive')))
        createImguiCheckbox(PASSIVE_ENABLE, 'passive', 'enable', 'settingPassiveEnable', 'tooltipSettingPassiveEnable')

        if PASSIVE_ENABLE.v then
            createImguiCheckbox(PASSIVE_TRACER, 'passive', 'showTempTracer', 'settingPassiveTracer',
                'tooltipSettingPassiveTracer')
            createImguiCheckbox(PASSIVE_STRING, 'passive', 'printStyledString', 'settingPassiveString',
                'tooltipSettingPassiveString')

            imgui.PushItemWidth(200)
            imgui.SliderInt(u8:encode(getMessage('settingPassiveCooldown')), PASSIVE_COOLDOWN, 6, 100)
            if PASSIVE_COOLDOWN.v ~= cfg.passive.cooldown and PASSIVE_COOLDOWN.v >= 6 and PASSIVE_COOLDOWN.v <= 100 then
                cfg.passive.cooldown = PASSIVE_COOLDOWN.v
                saveCfg()
            end
        end

        imgui.NewLine()

        imgui.Text(u8:encode(getMessage('sectionTactical')))
        createImguiCheckbox(TACTICAL_ENABLE, 'tactical', 'enable', 'settingTacticalEnable',
            'tooltipSettingTacticalEnable')

        if TACTICAL_ENABLE.v then
            imgui.TextColored(imgui.ImColor(255, 0, 0, 255):GetVec4(), u8:encode(getMessage('tacticalCheatWarning')))
            if imgui.Button(u8:encode(getMessage("tacticalHotkey") .. (TACTICAL_LMENU.v and "LEFT ALT + " or "") ..
                                          key.id_to_name(cfg.tactical.key))) then
                main_window_state.v = false
                table.insert(tempThreads, lua_thread.create(function()
                    sampShowDialog(767, getMessage('legacyChangeKeyTitle'), getMessage('legacyChangeKeyText'),
                        getMessage('legacyChangeKeyButton1'), getMessage('legacyChangeKeyButton2'))
                    while sampIsDialogActive(767) do
                        wait(100)
                    end
                    local resultMain, buttonMain, typ = sampHasDialogRespond(767)
                    local isThisBetterThanExtraDependency = true
                    if buttonMain == 1 then
                        while isThisBetterThanExtraDependency do
                            wait(0)
                            for i = 1, 200 do
                                if isKeyDown(i) then
                                    sampAddChatMessage(getMessage('legacyChangeKeySuccess') ..
                                                           (TACTICAL_LMENU.v and "LEFT ALT + " or "") ..
                                                           key.id_to_name(i), -1)
                                    cfg.tactical.key = i
                                    addOneOffSound(0.0, 0.0, 0.0, 1052)
                                    saveCfg()
                                    isThisBetterThanExtraDependency = false
                                    break
                                end
                            end
                        end
                    end
                    main_window_state.v = true
                end))
            end
            createImguiCheckbox(TACTICAL_LMENU, 'tactical', 'alt', 'settingTacticalAlt', 'tooltipSettingTacticalAlt')
            createImguiCheckbox(TACTICAL_INSTANT, 'tactical', 'instant', 'settingTacticalInstant',
                'tooltipSettingTacticalInstant')

            imgui.PushItemWidth(200)
            imgui.SliderInt(u8:encode(getMessage('settingTacticalCooldown')), TACTICAL_COOLDOWN, 5, 100)
            if TACTICAL_COOLDOWN.v ~= cfg.tactical.cooldown and TACTICAL_COOLDOWN.v >= 5 and TACTICAL_COOLDOWN.v <= 100 then
                cfg.tactical.cooldown = TACTICAL_COOLDOWN.v
                saveCfg()
            end
        end

        imgui.NewLine()

        imgui.Text(u8:encode(getMessage('sectionAudio')))

        if getVolume().radio == 0 and cfg.audio.volume ~= 0 then
            imgui.TextColored(imgui.ImColor(255, 0, 0, 255):GetVec4(),
                u8:encode(getMessage('radioDisabledWarningImgui')))
        end

        createImguiCheckbox(NO_RADIO, 'audio', 'noRadio', 'settingNoRadio', 'tooltipSettingNoRadio')

        createImguiCheckbox(AUDIO_IGNORE_MISSING_RESOURCES, 'audio', 'ignoreMissing', 'settingIgnoreMissing',
            'tooltipSettingIgnoreMissing')

        imgui.PushItemWidth(200)
        if imgui.Combo(u8:encode(getMessage('settingAudioLanguage')), AUDIO_LANGUAGE,
            i18n.audioLangTable[cfg.options.language], 10) then
            cfg.audio.language = audioLanguages[AUDIO_LANGUAGE.v + 1]
            playTestSound()
            saveCfg()
        end

        imgui.PushItemWidth(200)
        imgui.SliderInt(u8:encode(getMessage('settingVolume')), AUDIO_VOLUME, 0, 100)
        if AUDIO_VOLUME.v ~= cfg.audio.volume and AUDIO_VOLUME.v >= 0 and AUDIO_VOLUME.v <= 100 then
            cfg.audio.volume = AUDIO_VOLUME.v
            playTestSound()
            saveCfg()
        end

        imgui.PushItemWidth(200)
        imgui.SliderInt(u8:encode(getMessage('settingVolumeQuietOffset')), AUDIO_VOLUME_QUIET_OFFSET, 0, 100)
        if AUDIO_VOLUME_QUIET_OFFSET.v ~= cfg.audio.quietOffset and AUDIO_VOLUME_QUIET_OFFSET.v >= 0 and
            AUDIO_VOLUME_QUIET_OFFSET.v <= 100 then
            cfg.audio.quietOffset = AUDIO_VOLUME_QUIET_OFFSET.v
            stopMainSoundNow()
            stopReserveSoundNow()
            if math.random(1, 10) % 2 == 0 then
                playRandomFromCategory('aiming')
            else
                -- fix
                playReserveSoundNow(getWorkingDirectory() .. "\\resource\\wraith\\tactical_instant.mp3")
            end
            saveCfg()
        end

        if imgui.Button(u8:encode(getMessage('randomSound') .. CURRENT_RANDOM_SOUND)) then
            CURRENT_RANDOM_SOUND = getRandomSoundName()
            playTestSound()
        end

        if imgui.Button(u8:encode("PLAY")) then
            playTestSound()
        end

        imgui.NewLine()

        imgui.Text(u8:encode(getMessage('sectionDebug')))
        createImguiCheckbox(DEBUG, 'options', 'debug', 'settingDebug', 'tooltipSettingDebug')
        if DEBUG.v then
            createImguiCheckbox(DEBUG_NEED_AIMLINES, 'options', 'debugNeedAimLines', 'settingDebugNeedAimLines',
                'tooltipSettingDebugNeedAimLines')
            if DEBUG_NEED_AIMLINES.v then
                createImguiCheckbox(DEBUG_NEED_AIMLINES_FULL, 'options', 'debugNeedAimLinesFull',
                    'settingDebugNeedAimLinesFull', 'tooltipSettingDebugNeedAimLinesFull')
                createImguiCheckbox(DEBUG_NEED_AIMLINES_LOS, 'options', 'debugNeedAimLinesLOS',
                    'settingDebugNeedAimLinesLOS', 'tooltipSettingDebugNeedAimLinesLOS')
            end
            createImguiCheckbox(DEBUG_NEED_3DTEXT, 'options', 'debugNeed3dtext', 'settingDebugNeed3dtext',
                'tooltipSettingDebugNeed3dtext')
            createImguiCheckbox(DEBUG_NEED_AIMLINE, 'options', 'debugNeedAimLine', 'settingDebugNeedAimLine',
                'tooltipSettingDebugNeedAimLine')
            if DEBUG_NEED_AIMLINE.v then
                createImguiCheckbox(DEBUG_NEED_AIMLINE_FULL, 'options', 'debugNeedAimLineFull',
                    'settingDebugNeedAimLineFull', 'tooltipSettingDebugNeedAimLineFull')
                createImguiCheckbox(DEBUG_NEED_AIMLINE_LOS, 'options', 'debugNeedAimLineLOS',
                    'settingDebugNeedAimLineLOS', 'tooltipSettingDebugNeedAimLineLOS')
            end

            if DEBUG_NEED_AIMLINE.v or DEBUG_NEED_AIMLINES.v then
                createImguiCheckbox(DEBUG_NEED_DRAW_ANGLES, 'options', 'debugNeedToDrawAngles', 'settingDebugNeedDrawAngles', 'tooltipSettingDebugNeedDrawAngles')
                createImguiCheckbox(DEBUG_NEED_TO_TWEAK_ANGLES, 'options', 'debugNeedToTweakAngles', 'settingNeedToTweakAngles', 'tooltipSettingNeedToTweakAngles')
                createImguiCheckbox(DEBUG_NEED_TO_SAVE_ANGLES_INI, 'options', 'debugNeedToSaveAngles', 'settingNeedToSaveAnglesIni', 'tooltipSettingNeedToSaveAnglesIni')
            end
        end

        imgui.End()
    end
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg] = colors[clr.PopupBg]
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered] = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg] = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button] = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered] = ImVec4(0, 0, 0, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator] = colors[clr.Border]
    colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

-- debug
function saveDebugIniIfNeeded()
    if DEBUG.v and DEBUG_NEED_TO_SAVE_ANGLES_INI.v then
        inicfg.save(anglesPerAspectRatio, angelsIniFileName)
    end
end

saveDebugIniIfNeeded()

function camPos(x, y, z, x1, y1, z1)
    setFixedCameraPosition(x, y, z, x1, y1, z1)
    print("setFixedCameraPosition: ", x, y, z, x1, y1, z1)
end

function ponCameraPoint(x, y, z, m)
    pointCameraAtPoint(x, y, z, m)
    print("pointCameraAtPoint: ", x, y, z, m)
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

function processDebugOffset(aspect, weapon)
    if isKeyDown(0xA4) and (isKeyDown(0x25) or isKeyDown(0x26) or isKeyDown(0x27) or isKeyDown(0x28)) then
        local property1 = false
        local property2 = false

        if (weapon >= 22 and weapon <= 29) or weapon == 32 then
            property1 = "curxy"
            property2 = "curz"
        elseif weapon == 30 or weapon == 31 then
            property1 = "curARxy"
            property2 = "curARz"
        elseif weapon == 33 then
            property1 = "curRFxy"
            property2 = "curRFz"
        end

        if property1 and property2 then
            if isKeyDown(0x25) then
                -- left
                print(string.format('left'), 1, 1)
                anglesPerAspectRatio[aspect][property1] = anglesPerAspectRatio[aspect][property1] - 0.001
            elseif isKeyDown(0x26) then
                -- up
                print(string.format('up'), 1, 1)
                anglesPerAspectRatio[aspect][property2] = anglesPerAspectRatio[aspect][property2] + 0.001
            elseif isKeyDown(0x27) then
                -- right
                print(string.format('right'), 1, 1)
                anglesPerAspectRatio[aspect][property1] = anglesPerAspectRatio[aspect][property1] + 0.001
            elseif isKeyDown(0x28) then
                -- down
                print(string.format('down'), 1, 1)
                anglesPerAspectRatio[aspect][property2] = anglesPerAspectRatio[aspect][property2] - 0.001
            end

            saveDebugIniIfNeeded()
            wait(100)
        end
    end
end

-- cleanup
function onScriptTerminate(LuaScript, quitGame)
    for k, v in pairs(debug3dText) do
        sampDestroy3dText(v)
    end
end
