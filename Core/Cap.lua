local _, BD = ...

-- Number cap. AoE on many enemies can keep hundreds of numbers on screen, each updated every
-- frame. Each enemy keeps at most MAX_NUMBERS_PER_PLATE live numbers (MAX_NUMBERS_TARGET on your
-- target), and all of them at most MAX_NUMBERS. Past a cap a new number is not shown, except that
-- a crit replaces that enemy's oldest normal number, and your target is never cut by the total.
-- Screen areas keep their own limit (Core/LayoutScreen.lua).
local plateNumbers = setmetatable({}, { __mode = "k" }) -- plate -> its live numbers, oldest first

local function LiveOnPlate(plate)
    local list = plateNumbers[plate]
    if not list then
        return nil, 0
    end
    local write = 1
    for read = 1, #list do
        local frame = list[read]
        if frame:IsShown() and frame.anchor == plate and frame.capPlate == plate then
            list[write] = frame
            write = write + 1
        end
    end
    for index = write, #list do
        list[index] = nil
    end
    return list, write - 1
end

local Cap = {}
BD.Cap = Cap

-- True when the new number is not shown.
function Cap.OverPlateCap(plate, isTarget, isCrit)
    local list, count = LiveOnPlate(plate)
    local plateCap = isTarget and BD.MAX_NUMBERS_TARGET or BD.MAX_NUMBERS_PER_PLATE
    if count < plateCap and (isTarget or BD.Pool.ActiveCount() < BD.MAX_NUMBERS) then
        return false
    end
    if isCrit and list then
        for index = 1, count do
            local frame = list[index]
            if not frame.isCrit then
                table.remove(list, index)
                BD.Pool.Release(frame)
                return false
            end
        end
    end
    return true
end

-- A number shown on a plate counts against that plate.
function Cap.TrackPlate(plate, frame)
    frame.capPlate = plate
    local list = plateNumbers[plate]
    if not list then
        list = {}
        plateNumbers[plate] = list
    end
    -- A recycled frame may still be listed from its last life on this plate.
    for index = 1, #list do
        if list[index] == frame then
            table.remove(list, index)
            break
        end
    end
    list[#list + 1] = frame
end
