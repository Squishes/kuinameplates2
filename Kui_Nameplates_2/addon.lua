--------------------------------------------------------------------------------
-- Kui Nameplates
-- By Kesava at curse.com
-- All rights reserved
--------------------------------------------------------------------------------
-- Initialise addon events & begin to find nameplates
--------------------------------------------------------------------------------
-- initalise addon global
KuiNameplates = CreateFrame('Frame')
local addon = KuiNameplates
addon.debug = true
--addon.debug_units = true
--addon.debug_messages = true
--addon.draw_frames = true

local framelist = {}

-- plugin & element vars
local sort, tinsert = table.sort, tinsert
local function PluginSort(a,b)
    return a.priority > b.priority
end
addon.plugins = {}

-- this is the size of the container, not the visible frame
-- changing it will cause positioning problems
local width, height = 142, 40
--------------------------------------------------------------------------------
function addon:print(msg)
    if not addon.debug then return end
    print('|cff666666KNP2 '..GetTime()..':|r '..(msg and msg or nil))
end
function addon:Frames()
    local i = 0
    return function()
        i = i + 1
        if i <= #framelist then
            return framelist[i]
        end
    end
end
--------------------------------------------------------------------------------
function addon:NAME_PLATE_CREATED(frame)
    self:HookNameplate(frame)
    tinsert(framelist,frame)
end
function addon:NAME_PLATE_UNIT_ADDED(unit)
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if not f then return end

    if addon.debug_units then
        self:print('unit |cff88ff88added|r: '..unit..' ('..UnitName(unit)..')')
    end

    f.kui.handler:OnUnitAdded(unit)
end
function addon:NAME_PLATE_UNIT_REMOVED(unit)
    local f = C_NamePlate.GetNamePlateForUnit(unit)
    if not f then return end

    if f.kui:IsShown() then
        if addon.debug_units then
            self:print('unit |cffff8888removed|r: '..unit..' ('..f.kui.state.name..')')
        end

        f.kui.handler:OnHide()
    end
end
--------------------------------------------------------------------------------
local function OnEvent(self,event,...)
    if event ~= 'PLAYER_LOGIN' then
        if self[event] then
            self[event](self,...)
        end
        return
    end

    self.uiscale = UIParent:GetEffectiveScale()

    -- get the pixel-perfect width/height of the default, non-trivial frames
    self.width, self.height = floor(width / self.uiscale), floor(height / self.uiscale)

    -- initialise plugins & elements
    if #self.plugins > 0 then
        -- sort to be initialised by order of priority
        sort(self.plugins, PluginSort)

        for k,plugin in ipairs(self.plugins) do
            if type(plugin.Initialise) == 'function' then
                plugin:Initialise()
            end
        end
    end

    if not self.layout then
        -- throw missing layout
        print('|cff9966ffKui Namemplates|r: A compatible layout was not loaded. You probably forgot to enable Kui Nameplates: Core in your addon list.')
    else
        if type(self.layout.Initialise) == 'function' then
            self.layout:Initialise()
        end
    end

    addon:DispatchMessage('Initialised')
end
------------------------------------------- initialise addon scripts & events --
addon:SetScript('OnEvent',OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent('NAME_PLATE_CREATED')
addon:RegisterEvent('NAME_PLATE_UNIT_ADDED')
addon:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
