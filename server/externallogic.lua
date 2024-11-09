local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
local resourceName = 'Muhaddil/FiveM-MilageVehicleFailure'
local githubApiUrl = 'https://api.github.com/repos/' .. resourceName .. '/releases/latest'


if Config.AutoRunSQL then
    if not pcall(function()
            local fileName = "InstallSQL.sql"
            local file = assert(io.open(GetResourcePath(GetCurrentResourceName()) .. "/" .. fileName, "rb"))
            local sql = file:read("*all")
            file:close()

            MySQL.query.await(sql)
        end) then
        print(
        "^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
    end
end

-- Función para calcular la diferencia en días
local function daysAgo(dateStr)
    local year, month, day = dateStr:match("(%d+)-(%d+)-(%d+)")
    local releaseTime = os.time({ year = year, month = month, day = day })
    local currentTime = os.time()
    local difference = os.difftime(currentTime, releaseTime) / (60 * 60 * 24) -- Diferencia en días
    return math.floor(difference)
end

-- Función para convertir la fecha a "hace X días"
local function formatDate(releaseDate)
    local days = daysAgo(releaseDate)
    if days < 1 then
        return "Today"
    elseif days == 1 then
        return "Yesterday"
    else
        return days .. " days ago"
    end
end

-- Función para acortar la URL
local function shortenTexts(text)
    local maxLength = 35
    if #text > maxLength then
        local shortened = text:sub(1, maxLength - 3) .. '...'
        return shortened
    else
        return text
    end
end

local function printWithColor(message, colorCode)
    if type(message) ~= "string" then
        message = tostring(message)
    end
    print('\27[' .. colorCode .. 'm' .. message .. '\27[0m')
end

local function printCentered(text, length, colorCode)
    local padding = math.max(length - #text - 2, 0)
    local leftPadding = math.floor(padding / 2)
    local rightPadding = padding - leftPadding
    printWithColor('│' .. string.rep(' ', leftPadding) .. text .. string.rep(' ', rightPadding) .. '│', colorCode)
end

local function printWrapped(text, length, colorCode)
    if type(text) ~= "string" then
        text = tostring(text)
    end

    local maxLength = length - 2
    local pos = 1

    while pos <= #text do
        local endPos = pos + maxLength - 1
        if endPos > #text then
            endPos = #text
        else
            local spaceIndex = text:sub(pos, endPos):match('.*%s') or maxLength
            endPos = pos + spaceIndex - 1
        end

        local line = text:sub(pos, endPos)
        if endPos < #text then
            line = line .. '...'
        end

        printWithColor('│' .. line .. string.rep(' ', length - #line) .. '│', colorCode)

        pos = endPos + 1
    end
end

if Config.AutoVersionChecker then
    PerformHttpRequest(githubApiUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)

            if data and data.tag_name then
                local latestVersion = data.tag_name
                local releaseDate = data.published_at or "Unknown"
                local formattedDate = formatDate(releaseDate)
                local notes = data.body or "No notes available"
                local downloadUrl = data.html_url or "No download link available"
                local shortenedUrl = shortenTexts(downloadUrl)
                local shortenedNotes = shortenTexts(notes)


                local boxWidth = 52

                if latestVersion ~= currentVersion then
                    print('╭────────────────────────────────────────────────────╮')
                    printCentered('[FiveM-MilageVehicleFailure] - New Version Available', boxWidth, '34') -- Blue
                    printWrapped('Current version: ' .. currentVersion, boxWidth, '32')                   -- Green
                    printWrapped('Latest version: ' .. latestVersion, boxWidth, '33')                     -- Yellow
                    printWrapped('Released: ' .. formattedDate, boxWidth, '33')                           -- Yellow
                    printWrapped('Notes: ' .. shortenedNotes, boxWidth, '33')                             -- Yellow
                    printWrapped('Download: ' .. shortenedUrl, boxWidth, '32')                            -- Green
                    print('╰────────────────────────────────────────────────────╯')
                else
                    print('╭────────────────────────────────────────────────────╮')
                    printWrapped('[FiveM-MilageVehicleFailure] - Up-to-date', boxWidth, '32') -- Green
                    printWrapped('Current version: ' .. currentVersion, boxWidth, '32')       -- Green
                    print('╰────────────────────────────────────────────────────╯')
                end
            else
                printWithColor('[FiveM-MilageVehicleFailure] - Error: The JSON structure is not as expected.', '31') -- Red
                printWithColor('GitHub API Response: ' .. response, '31')                                            -- Red
            end
        else
            printWithColor(
            '[FiveM-MilageVehicleFailure] - Failed to check for latest version. Status code: ' .. statusCode, '31')                -- Red
        end
    end, 'GET')
end
