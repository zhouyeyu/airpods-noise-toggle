-- 双击 Option 键切换 AirPods 模式 (通透 ↔ 降噪)

local lastOptionPress = 0
local doubleClickThreshold = 0.3
local optionDown = false

local function toggleANCMode()
    local script = [[
        tell application "System Events"
            tell application process "ControlCenter"
                try
                    click (first menu bar item of menu bar 1 whose description is "声音")
                    delay 0.3

                    set allElems to entire contents of window 1
                    
                    set triangleIdx to -1
                    repeat with i from 1 to count of allElems
                        try
                            set elem to item i of allElems
                            if (description of elem as string) is "显示三角形" then
                                set triangleIdx to i
                                if (value of elem as integer) is 0 then
                                    click elem
                                    delay 0.3
                                    set allElems to entire contents of window 1
                                end if
                                exit repeat
                            end if
                        end try
                    end repeat
                    
                    if triangleIdx is -1 then
                        key code 53
                        return "未找到 AirPods 展开按钮"
                    end if
                    
                    -- 找到三角形后面的"标题"元素，降噪选项在标题之后
                    set titleIdx to -1
                    repeat with i from (triangleIdx + 1) to (count of allElems)
                        try
                            set elem to item i of allElems
                            if (description of elem as string) is "标题" then
                                set titleIdx to i
                                exit repeat
                            end if
                        end try
                    end repeat
                    
                    if titleIdx is -1 then
                        key code 53
                        return "未找到降噪模式标题"
                    end if
                    
                    -- 从标题之后收集 4 个 checkbox: 关闭、通透、自适应、降噪
                    set modeCheckboxes to {}
                    repeat with i from (titleIdx + 1) to (count of allElems)
                        try
                            set elem to item i of allElems
                            if class of elem is checkbox then
                                set end of modeCheckboxes to elem
                                if (count of modeCheckboxes) is 4 then exit repeat
                            end if
                        end try
                    end repeat
                    
                    if (count of modeCheckboxes) < 4 then
                        key code 53
                        return "未找到降噪模式选项"
                    end if
                    
                    -- 索引: 1=关闭, 2=通透, 3=自适应, 4=降噪
                    set transparentCheckbox to item 2 of modeCheckboxes
                    set ancCheckbox to item 4 of modeCheckboxes
                    
                    set isANC to (value of ancCheckbox as integer) is 1
                    
                    if isANC then
                        -- 当前是降噪，切换到通透
                        click transparentCheckbox
                        delay 0.1
                        key code 53
                        return "已切换到 通透"
                    else
                        -- 当前是其他模式，切换到降噪
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
