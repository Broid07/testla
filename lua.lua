mysql = exports.mysql:getConnection()

addEventHandler("onPlayerJoin", root, function()
    serial = getPlayerSerial(source)
    spawnPlayer(source, 0, 0, 0)
    setElementFrozen(source, true)
    fadeCamera(source, true)
    setCameraTarget(source)
    showChat(source, false)
    check(source, "check", serial)
end)

function check(player, type, serial)
    dbQuery(function(qh)
        local results = dbPoll(qh, 0)
        results = results[1]
        if results then
            if type == "check" then
                dbid = results.id
                admin_level = results.admin
                charright = results.charright
                setElementData(player, "admin", admin_level)
                setElementData(player, "dbid", dbid)
                setElementData(player, "charright", charright)

                charone = fromJSON(results.charone)
                chartwo = fromJSON(results.chartwo)
                charthree = fromJSON(results.charthree)
                
                triggerClientEvent(player, "client:draw", player, "charlogin", charone, chartwo, charthree)
            end
        else
            dbExec(mysql, "INSERT INTO auth (serial) VALUES (?)", serial)
            check(player, "check", serial)
        end
    end, mysql, "SELECT * FROM auth WHERE serial = ?", serial)
end

addEvent("spawn:character", true)
addEventHandler("spawn:character", root, function(name, money, bankmoney, skin, int, dim, x, y, z)
    if name == "bos" then
    else
        setPlayerName(source, name)
        setElementData(source, "money", money)
        setElementData(source, "bankmoney", bankmoney)
    
        showChat(source, true)
        spawnPlayer(source, x, y, z)
        setElementModel(source, skin)
        setCameraTarget(source)
        fadeCamera(source, true)
        setElementFrozen(source, false)
        dbid = getElementData(source, "dbid")
        triggerEvent("vehicle:load", source, dbid)
    end
end)

addEvent("create:character", true)
addEventHandler("create:character", root, function(name, age, kilo, boy, model, char)
    if char == 1 then
        char = "charone"
    elseif char == 2 then
        char = "chartwo"
    elseif char == 3 then
        char = "charthree"
    end
    serial = getPlayerSerial(source)
    tablo = {}
    table.insert(tablo, {charname = name, pozisyon = {2025.9382324219, -1422.7154541016, 16.9921875}, skin = model, money = 1500, int = 0, dim = 0, bankmoney = 0, age = age, boy = boy, kilo = kilo})
    
    query = "UPDATE auth SET "..char.." = ? WHERE serial = ?"
    dbExec(mysql, query, toJSON(tablo), serial)
    triggerEvent("spawn:character", source, name, 1500, 0, model, 0, 0, 2025.9382324219, -1422.7154541016, 16.9921875)
end)