local addonName, BD = ...

-- /psct perf: every few seconds, print how much frame time PlateSCT takes (Blizzard's addon
-- profiler, C_AddOnProfiler), how many numbers are live and how many hits arrive. Read-only; meant
-- for reporting lag in big pulls. Toggle off with /psct perf again.
local PERF_INTERVAL = 5

local perfOn = false
local perfRun = 0 -- bumped on each toggle, so timers from an earlier run stop
local requests, peakNumbers = 0, 0
local originalShow, originalCombat
-- Milliseconds spent since the last report: hit handling, and number updates with the position
-- snapshots among them (filled by Pool.lua).
local times = { hits = 0, numbers = 0, snapshot = 0 }

local function Metric(kind)
    if not (C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric and Enum and Enum.AddOnProfilerMetric) then
        return nil
    end
    local ok, value = pcall(C_AddOnProfiler.GetAddOnMetric, addonName, Enum.AddOnProfilerMetric[kind])
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

local function Report()
    local live = BD.Pool.ActiveCount and BD.Pool.ActiveCount() or 0
    if live > peakNumbers then
        peakNumbers = live
    end
    local fps = GetFramerate and GetFramerate() or 0
    local recent, peak = Metric("RecentAverageTime"), Metric("PeakTime")
    local cpu
    if recent then
        local share = fps > 0 and recent / (1000 / fps) * 100 or 0
        cpu = string.format("%.2f ms/frame (%.0f%% of a frame), peak %.1f ms", recent, share, peak or 0)
    else
        cpu = "addon profiler unavailable"
    end
    print(string.format("|cff66ccffPlateSCT perf:|r %s | %d fps | numbers %d (peak %d) | %d hits/s",
        cpu, fps, live, peakNumbers, requests / PERF_INTERVAL))
    local frames = math.max(1, fps * PERF_INTERVAL)
    local other = recent and math.max(0, recent - (times.hits + times.numbers) / frames)
    print(string.format("   ms/frame: hits %.3f | numbers %.3f (snapshot %.3f)%s",
        times.hits / frames, times.numbers / frames, times.snapshot / frames,
        other and string.format(" | other (timers) %.3f", other) or ""))
    for key in pairs(times) do
        times[key] = 0
    end
    requests, peakNumbers = 0, 0
end

local function Sample(run, untilReport)
    if not perfOn or run ~= perfRun then
        return
    end
    local live = BD.Pool.ActiveCount and BD.Pool.ActiveCount() or 0
    if live > peakNumbers then
        peakNumbers = live
    end
    untilReport = untilReport - 0.25
    if untilReport <= 0 then
        Report()
        untilReport = PERF_INTERVAL
    end
    C_Timer.After(0.25, function()
        Sample(run, untilReport)
    end)
end

function BD:TogglePerf()
    perfRun = perfRun + 1
    if perfOn then
        perfOn = false
        if originalShow then
            BD.ShowOnNameplate, originalShow = originalShow, nil
        end
        if originalCombat then
            BD.HandleUnitCombat, originalCombat = originalCombat, nil
        end
        BD.Pool.SetPerfTimes(nil)
        print("|cff66ccffPlateSCT perf:|r off")
        return
    end
    originalShow = BD.ShowOnNameplate
    BD.ShowOnNameplate = function(...)
        requests = requests + 1
        return originalShow(...)
    end
    -- Hit handling time (Modern: UNIT_COMBAT goes through HandleUnitCombat).
    if BD.HandleUnitCombat and debugprofilestop then
        originalCombat = BD.HandleUnitCombat
        BD.HandleUnitCombat = function(...)
            local t = debugprofilestop()
            originalCombat(...)
            times.hits = times.hits + (debugprofilestop() - t)
        end
    end
    if debugprofilestop then
        BD.Pool.SetPerfTimes(times)
    end
    requests, peakNumbers, perfOn = 0, 0, true
    local run = perfRun
    C_Timer.After(0.25, function()
        Sample(run, PERF_INTERVAL)
    end)
    print("|cff66ccffPlateSCT perf:|r on, a report every " .. PERF_INTERVAL .. " s (/psct perf to stop)")
end
