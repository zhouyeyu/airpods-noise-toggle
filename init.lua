-- 双击 Option 键切换 AirPods 降噪模式 (降噪 ↔ 自适应)
-- 通过 AppleScript UI 脚本控制声音菜单

local lastOptionPress = 0
local doubleClickThreshold = 0.3 -- 双击间隔（秒）
local optionDown = false

-- AppleScript: 切换 AirPods 降噪模式
local function toggleANCMode()
    local script = [[
        tell application "System Events"
            tell application process "ControlCenter"
                try
                    -- 找到声音菜单
                    set soundMenu to missing value
                    set menuBarItems to menu bar items of menu bar 1
                    repeat with menuItem in menuBarItems
                        try
                            if description of menuItem is "声音" then
                                set soundMenu to menuItem
                                exit repeat
                            end if
                        end try
                    end repeat

                    if soundMenu is missing value then
                        return "未找到声音菜单"
                    end if

                    click soundMenu
                    delay 0.2

                    -- 找到滚动区域
                    set scrollArea to missing value
                    set allElements to entire contents of window 1
                    repeat with elem in allElements
                        try
                            if role of elem is "AXScrollArea" then
                                set scrollArea to elem
                                exit repeat
                            end if
                        end try
                    end repeat

                    if scrollArea is missing value then
                        key code 53
                        return "未找到滚动区域"
                    end if

                    -- AirPods 在第 3 个位置，点击展开
                    set allCheckboxes to checkboxes of scrollArea
                    set airpodsCheckbox to item 3 of allCheckboxes

                    -- 检查 AirPods 是否已选中
                    if (value of airpodsCheckbox as integer) is not 1 then
                        key code 53
                        return "AirPods 未连接或未选中"
                    end if

                    -- 找到 AirPods 旁边的展开按钮并点击（如果未展开）
                    set allElems to entire contents of scrollArea
                    set airpodsIdx to -1
                    repeat with i from 1 to count of allElems
                        if item i of allElems is equal to airpodsCheckbox then
                            set airpodsIdx to i
                            exit repeat
                        end if
                    end repeat

                    if airpodsIdx > 0 then
                        repeat with j from (airpodsIdx + 1) to (airpodsIdx + 5)
                            if j > (count of allElems) then exit repeat
                            try
                                set elem to item j of allElems
                                if role of elem is "AXDisclosureTriangle" then
                                    set isExpanded to value of elem as boolean
                                    if isExpanded is false then
                                        click elem
                                        delay 0.15
                                    end if
                                    exit repeat
                                end if
                            end try
                        end repeat
                    end if

                    -- 重新获取 checkboxes
                    -- AirPods Pro 聆听模式: 通透(4) / 自适应(5) / 降噪(6)
                    set allCheckboxes to checkboxes of scrollArea

                    set adaptiveCheckbox to item 5 of allCheckboxes  -- 自适应
                    set ancCheckbox to item 6 of allCheckboxes       -- 降噪

                    set isANC to (value of ancCheckbox as integer) is 1

                    if isANC then
                        -- 当前是降噪，切换到自适应
                        click adaptiveCheckbox
                        delay 0.1
                        key code 53
                        return "已切换到 自适应"
                    else
                        -- 切换到降噪
                        click ancCheckbox
                        delay 0.1
                        key code 53
                        return "已切换到 降噪"
                    end if

                on error errMsg
                    try
                        key code 53
                    end try
                    return "错误: " & errMsg
                end try
            end tell
        end tell
    ]]

    hs.osascript.applescript(script, function(success, result, rawOutput)
        if success and result then
            hs.alert.show("🎧 " .. tostring(result), 1.5)
        else
            hs.alert.show("切换失败", 1)
        end
    end)
end

local optionTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(event)
    local flags = event:getFlags()
    local isOptionOnly = flags.alt and not flags.cmd and not flags.ctrl and not flags.shift

    if isOptionOnly and not optionDown then
        optionDown = true
        local now = hs.timer.secondsSinceEpoch()
        if (now - lastOptionPress) < doubleClickThreshold then
            -- 双击检测成功
            toggleANCMode()
            lastOptionPress = 0
        else
            lastOptionPress = now
        end
    elseif not flags.alt then
        optionDown = false
    end
end)

optionTap:start()
hs.alert.show("Hammerspoon 已加载 ✓", 1.5)
