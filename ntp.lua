-- NeTask Packages
local repo = "https://github.com/netaskmc/ntp-cc"
args = {...}

local function pullFile(path)
    local url = repo:gsub("github.com", "raw.githubusercontent.com").."/main/"..path
    local response = http.get(url)
    if response == nil then return nil end
    if response.getResponseCode() ~= 200 then return nil end
    print("...pulling "..path)
    return response.readAll()
end

local function pullDir(path, ignore)
    local url = repo:gsub("github.com", "api.github.com/repos").."/contents/"..path
    local response = http.get(url)
    if response == nil then return nil end
    local files = textutils.unserialiseJSON(response.readAll())
    local out = {}
    for i, file in pairs(files) do
        if not table.contains(ignore, file.name) then 
            if file.type == "file" then
                out[file.path] = pullFile(file.path)
                if out[file.path] == nil then error("failed to pull "..file.path) end
            elseif file.type == "dir" then
                local newIgnore = {}
                for i, v in pairs(ignore) do
                    -- if starts with directory name, strip it and add to newIgnore
                    if v:sub(1, #path + 1) == path.."/" then
                        newIgnore:insert(v:sub(#path + 2))
                    end
                end
                for n, f in pairs(pullDir(file.path, newIgnore)) do
                    out[file.path.."/"..n] = f
                end
            end
        end
    end
    return out
end

local function resolvePackage(name, pull)
    local files = {}
    local packageMeta = {
        name = name,
        type = "program"
    }
    local script = pullFile(name..".lua")
    if script == nil then 
        local metaStr = pullFile(name.."/ntpackage.lua")
        if metaStr == nil then return nil end

        packageMeta = loadstring(metaStr)()
        if packageMeta.ignore == nil then packageMeta.ignore = {} end
        packageMeta.ignore:insert("ntpackage.lua")

        if pull then
            local dir = pullDir(name, packageMeta.ignore)
            for n, f in pairs(dir) do
                files[n] = f
            end
        end
    else
        files[name..".lua"] = script
    end

    return packageMeta, files
end

local function installPackage(package, files)
    if package == nil then error("package ".. name .." not found") end
    print("Installing "..package.name.."...")
    local installDir = ""
    if package.type == "program" then
        installDir = "/rom/programs/"
    elseif package.type == "library" or package.type == "lib" then
        installDir = "/rom/modules/main/"
    end
    for n, f in pairs(files) do
        local file = fs.open(n, "w")
        file.write(f)
        file.close()
    end
    return package
end

if args[1] == nil then error("Usage: ntp [install|run] <package>") end

if args[1] == "install" or args[1] == "i" then
    if args[2] == nil then error("Usage: ntp ".. args[1] .." <package>") end
    local package, files = resolvePackage(args[2], true)
    installPackage(package, files)
end

if args[1] == "run" or args[1] == "x" then
    if args[2] == nil then error("Usage: ntp ".. args[1] .." <package>") end
    local package = resolvePackage(args[2], false)
    if package == nil then error("package ".. args[2] .." not found") end
    if package.type ~= "program" then error("package ".. args[2] .." is not a program") end

    local path = shell.resolveProgram(args[2])
    if path == nil then
        print("Package "..args[2].." not found, installing...")
        local package, files = resolvePackage(args[2], true)
        installPackage(package, files)
        path = shell.resolveProgram(args[2])
    end
end
