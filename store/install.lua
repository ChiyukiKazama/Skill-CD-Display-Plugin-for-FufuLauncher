-- Store ID, archive DLL and installation folder must all be DisplayCD.
local plugin_id = "DisplayCD"
local directory = install.get_plugins_dir() .. "\\" .. plugin_id
local config = directory .. "\\config.ini"
local backup = directory .. "\\config.pre-update.ini"
-- Recover an interrupted prior update before creating a fresh backup.
if install.file_exists(backup) then
    install.copy_file(backup, config)
    install.delete(backup)
end
local existed = install.file_exists(config)
if existed then
    install.copy_file(config, backup)
    if not install.file_exists(backup) then error("Could not back up DisplayCD configuration") end
end
local ok, result = pcall(install.download_plugin, plugin_id)
-- Restore exact bytes on success, returned failure, or a catchable Lua error.
-- An uncaught host cancellation leaves the backup for the next installation.
if existed then
    install.copy_file(backup, config)
    install.delete(backup)
end
if not ok then error(result) end
if not result or not result.success then error(result and result.error or "DisplayCD installation failed") end
