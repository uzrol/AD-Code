; personal project for anime defenders
#Requires AutoHotkey v2.0 64-bit
#SingleInstance Force
Persistent false

#Include lib\Gdip_ImageSearch.ahk
#Include lib\Gdip_All.ahk
#Include lib\OCR.ahk
#Include lib\endys_utilities.ahk

SendMode "Event"
loopFlag := false
f1:: StartMacro()
f3:: StopMacro()

if A_ScreenHeight != 1080 and A_ScreenWidth != 1920 {
    MsgBox "Your screen resolution is not 1920x1080! Change it to proceed. (go to display settings in Windows for that)"
    ExitApp
}
if A_ScreenDPI != 96 {
    MsgBox "Your screen scale is not 100%! Change it to proceed. (go to display settings in Windows for that)"
    ExitApp
}

SetWorkingDir A_InitialWorkingDir
DetectHiddenWindows true
CoordMode "Pixel", "Screen"

workingscripts := [] ; currently working scripts (to do)
gameloopPIDvar := 0 ; game loop PID to close it when needed
; gui thingie

if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
    myGui := Constructor()
    myGui.Show("w499 h400")
}
gdiptoken := 0
Constructor()
{
    try {
        myGui := Gui()
        myGui.Opt("-Resize")
        myGui.BackColor := "0xDFDFDF"
        myGui.Add("Text", "x8 y16 w482 h2 +0x10")
        myGui.Add("Text", "x8 y356 w482 h2 +0x10")
        myGui.Add("Text", "x8 y16 w1 h342 +0x1 +0x10")
        myGui.Add("Text", "x488 y16 w1 h342 +0x1 +0x10")
        ButtonF1Start := myGui.Add("Button", "x7 y373 w80 h23", "F1 - Start")
        ButtonF3Stop := myGui.Add("Button", "x90 y373 w80 h23", "F3 - Stop")
        myGui.Add("Picture", "x462 y355 w30 h30", "lib\images\Logo.png")
        myGui.SetFont("s11 w400", "Source Code Pro")
        Tab := myGui.Add("Tab3", "x11 y16 w461 h340 -Wrap +Buttons", ["Main", "Summon", "Status", "Settings"])
        Tab.UseTab(1)
        ; Main tab
        myGui.Add("Text", "x206 y56 w230 h2 +0x10")
        CheckBox1 := myGui.Add("CheckBox", "vDoChallenges x32 y72 w75 h14", "Enable")
        CheckBox1.Value := IniRead("config.ini", "Config", "doChallenges")
        myGui.Add("Text", "x32 y96 w74 h16 +0x200", "Frequency")
        myGui.Add("Text", "x100 y96 w74 h16 +0x200", "(in minutes)")
        myGui.Add("Text", "x32 y116 w40 h16 +0x200", "")
        Frequency := myGui.AddUpDown("vFrequency Range60-600 x33 y96 w150", IniRead("config.ini", "Config", "challengesFrequency"))
        myGui.Add("Text", "x16 y56 w180 h2 +0x10", "")
        myGui.Add("Text", "x32 y140 w80 h16", "Fail retries")
        myGui.Add("Text", "x32 y160 w40 h16", "")
        Retries := myGui.AddUpDown("vChalllengeRetry Range0-5 x33 y150 w150", IniRead("config.ini", "Config", "challengeRetry"))
        CheckBox7 := myGui.Add("CheckBox", "vDoToe x32 y226 w75 h14", "Enable")
        CheckBox7.Value := IniRead("config.ini", "Config", "doToE")
        myGui.Add("Text", "x32 y250 w74 h16 +0x200", "Frequency")
        myGui.Add("Text", "x100 y250 w74 h16 +0x200", "(in minutes)")
        myGui.Add("Text", "x32 y270 w40 h16 +0x200", "")
        ToeFrequency := myGui.AddUpDown("vToEFrequency Range60-600 x33 y270 w150", IniRead("config.ini", "Config", "toeFrequency"))
        myGui.Add("Text", "x16 y56 w180 h2 +0x10", "")
        myGui.Add("Text", "x32 y295 w80 h16", "Fail retries")
        myGui.Add("Text", "x32 y315 w40 h16", "")
        ToeRetries := myGui.AddUpDown("vToERetry Range0-5 x33 y150 w150", IniRead("config.ini", "Config", "toeRetry"))
        myGui.Add("Text", "x120 y56 w180 h2 +0x10", "")
        myGui.Add("Text", "x120 y295 w80 h16", "Victory limit")
        myGui.Add("Text", "x120 y315 w40 h16", "")
        ToeVictory := myGui.AddUpDown("vToEVictory Range1-100 x33 y150 w150", IniRead("config.ini", "Config", "toeVictory"))
        myGui.SetFont("w600")
        myGui.Add("Text", "x16 y210 w180 h2 +0x10")
        myGui.Add("Text", "x24 y200 w116 h25 +0x200", "Tower of Eternity")
        myGui.Add("Text", "x16 y340 w180 h2 +0x10")
        myGui.Add("Text", "x195 y210 w2 h130 +0x1 +0x10")
        myGui.Add("Text", "x15 y210 w2 h130 +0x1 +0x10")
        myGui.Add("Text", "x24 y43 w79 h25 +0x200", "Challenges")
        myGui.Add("Text", "x16 y183 w180 h2 +0x10")
        myGui.Add("Text", "x195 y56 w2 h130 +0x1 +0x10")
        myGui.Add("Text", "x15 y56 w1 h130 +0x1 +0x10")
        myGui.Add("Text", "x205 y56 w2 h170 +0x1 +0x10")
        myGui.SetFont("w600")
        myGui.Add("Text", "x215 y42 w34 h23 +0x200", "Main")
        myGui.SetFont("w400")
        myGui.Add("Text", "x215 y64 w130 h23 +0x200", "")
        myGui.Add("Text", "x215 y64 w160 h23 +0x200", "Loop time limit (in minutes)")
        myGui.Add("Text", "x215 y80 w160 h23 +0x200", "")
        myGui.Add("Text", "x215 y116 w160 h23 +0x200", "Units")
        myGui.Add("Text", "x215 y132 w160 h23 +0x200", "")
        unit1 := myGui.AddCheckbox("vUnit1 x215 y132 w30 h23", "1")
        unit1.Value := IniRead("config.ini", "config", "unit1")
        unit2 := myGui.AddCheckbox("vUnit2 x245 y132 w30 h23", "2")
        unit2.Value := IniRead("config.ini", "config", "unit2")
        unit3 := myGui.AddCheckbox("vUnit3 x275 y132 w30 h23", "3")
        unit3.Value := IniRead("config.ini", "config", "unit3")
        unit4 := myGui.AddCheckbox("vUnit4 x305 y132 w30 h23", "4")
        unit4.Value := IniRead("config.ini", "config", "unit4")
        unit5 := myGui.AddCheckbox("vUnit5 x335 y132 w30 h23", "5")
        unit5.Value := IniRead("config.ini", "config", "unit5")
        unit6 := myGui.AddCheckbox("vUnit6 x365 y132 w30 h23", "6")
        unit6.Value := IniRead("config.ini", "config", "unit6")
        myGui.Add("Text", "x215 y90 w40 h16 +0x200", "")
        GameLoopTimeLimit := myGui.AddUpDown("vTimeLimit Range1-120 x218 y90 w69 h16", IniRead("config.ini", "Config", "timeLimit"))
        myGui.Add("Text", "x215 y170 w120 h16 +0x200", "Infinite mode map")
        infinitemap1 := myGui.AddDropDownList("vInfiniteMap x212 y190 w150 h100", ["Windmill Village", "Haunted City", "Cursed Academy", "Blue Planet", "Underwater Temple", "Swordsman Dojo", "Snowy Woods", "Crystal Caves"])
        infinitemap1.Value := IniRead("config.ini", "Config", "infiniteMap")
        myGui.Add("Text", "x206 y223 w230 h2 +0x10")
        myGui.Add("Text", "x435 y56 w2 h170 +0x1 +0x10")
        Tab.UseTab(2)
        ;Auto summon tab
        myGui.SetFont("w600")
        myGui.Add("Text", "x16 y56 w230 h2 +0x10")
        myGui.Add("Text", "x24 y43 w95 h25 +0x200", "Auto summon")
        autosummonhelp := myGui.AddButton("vAutoSummonHelp x190 y60 w50 h25", "Help")
        myGui.Add("Text", "x16 y303 w230 h2 +0x10")
        myGui.Add("Text", "x242 y56 w2 h250 +0x1 +0x10")
        myGui.Add("Text", "x15 y56 w1 h250 +0x1 +0x10")
        myGui.SetFont("w400")
        myGui.Add("Text", "x33 y65 w1 h1 +0x1 +0x10")
        autosummon := myGui.AddCheckbox("vAutoSummon x33 y73 w110 h14", "Auto summon")
        autosummon.Value := IniRead("config.ini", "Config", "autosummon")
        hourlybanners := myGui.AddCheckbox("vHourlyBanners x33 y95 w100 h35", "Send hourly banners")
        hourlybanners.Value := IniRead("config.ini", "Config", "hourlybanner")
        myGui.Add("Text", "x35 y140 w100 h20", "Gems minimum")

        mingems := myGui.AddSlider("vMinGems Page100 Range500-100000 x33 y155 w200 h25")
        mingems.Value := IniRead("config.ini", "Config", "autosummongemsminimum")
        mingemsvalue := myGui.Add("Text", "vMinGemsValue x100 y180 w50 h20")
        mingemsvalue.Value := IniRead("config.ini", "Config", "autosummongemsminimum")
        myGui.AddText("x33 y200 w90 h15", "Max summons")
        myGui.AddText("x33 y220 w50 h19", "")
        maxrolls := myGui.AddUpDown("vMaxRolls Range1-1000 x33 y200 w50 h15")
        myGui.AddText("x150 y200 w90 h15", "Max units")
        myGui.AddText("x150 y220 w50 h19", "")
        maxunits := myGui.AddUpDown("vMaxUnits Range1-200 x33 y200 w50 h15")
        maxunits.Value := IniRead("config.ini", "Config", "autosummonmaxunits")
        maxrolls.Value := IniRead("config.ini", "Config", "autosummonmaxsummons")
        myGui.AddText("x33 y245 w100 h15", "Unit keywords")
        myGui.SetFont("s15")
        keywords := myGui.AddEdit("vKeywords x33 y265 w180 h30", "")
        keywords.Value := IniRead("config.ini", "Config", "autosummonunits")
        myGui.SetFont("s11")

        Tab.UseTab(3)
        ; Status tab
        myGui.Add("Text", "x16 y56 w198 h2 +0x10")
        myGui.SetFont("w600")
        myGui.Add("Text", "x26 y44 w67 h23 +0x200", "Webhook")
        myGui.SetFont("w400")
        CheckBox5 := myGui.Add("CheckBox", "vWebhookMessages x24 y65 w171 h23", "Webhook messages")
        CheckBox5.Value := IniRead("config.ini", "Config", "webhookMessages")
        Edit1W := myGui.Add("Edit", "vWebhookURL x24 y112 w180 h21", IniRead("config.ini", "Config", "webhookURL"))
        myGui.Add("Text", "x27 y92 w100 h17 +0x200", "Webhook URL")
        Edit1 := myGui.Add("Edit", "vPingID x24 y158 w180 h21", IniRead("config.ini", "Config", "pingID"))
        myGui.Add("Text", "x27 y138 w100 h17 +0x200", "Ping user ID")
        myGui.SetFont("s9")
        myGui.Add("Text", "x27 y190 w100 h15 +0x200", "Gems/Inventory ")
        myGui.Add("Text", "x27 y206 w160 h15 +0x200", "screenshots frequency (minutes)")
        myGui.SetFont("s11 w400")
        myGui.Add("Text", "x27 y225 w40 h16 +0x200", "")
        Edit1A := myGui.Add("UpDown", "vSsFreq Range30-720 x24 y240 w60 h23", IniRead("config.ini", "Config", "screenshotFrequency"))
        myGui.SetFont("s9")
        myGui.Add("Text", "x27 y260 w150 h30", "Game status messages frequency (minutes)")
        myGui.SetFont("s11")
        myGui.Add("Text", "x27 y290 w40 h16", "")
        StatusFreq := myGui.Add("UpDown", "vStatusFreq Range1-30 x24 y240 w60 h23", IniRead("config.ini", "Config", "statusFrequency"))
        myGui.Add("Text", "x16 y56 w1 h290 +0x1 +0x10")
        myGui.Add("Text", "x212 y56 w2 h290 +0x1 +0x10")
        myGui.Add("Text", "x16 y342 w198 h2 +0x10")
        myGui.Add("Text", "x225 y57 w2 h92 +0x1 +0x10")
        myGui.Add("Text", "x226 y57 w198 h2 +0x10")
        myGui.SetFont("w600")
        myGui.Add("Text", "x234 y45 w79 h23 +0x200", "Reconnect")
        myGui.SetFont("w300")
        Edit2 := myGui.Add("Edit", "vPrivateServerLink x235 y90 w179 h21", IniRead("config.ini", "Config", "privateServerLink"))
        myGui.SetFont("w400")
        myGui.Add("Text", "x238 y70 w140 h17 +0x200", "Private Server Link")
        myGui.Add("Text", "x423 y57 w1 h92 +0x1 +0x10")
        myGui.Add("Text", "x226 y147 w198 h2 +0x10")
        Tab.UseTab(4)
        myGui.SetFont("w600")
        myGui.Add("Text", "x24 y43 w79 h25 +0x200", "Settings")
        myGui.SetFont("w400")
        configimport := myGui.AddButton("x24 y75 w100 h25", "Import config")
        multimacrosettingsbutton := myGui.AddButton("x24 y115 w100 h40", "Multi macro settings")
        vipgamepass := myGui.AddCheckbox("vHasVip x150 y50 w150 h80", "Vip gamepass (used for auto summon price calculation)")
        vipgamepass.Value := IniRead("config.ini", "Config", "hasvip")
        Tab.UseTab()

        multimacrosettings := Gui("-Resize", "Multi macro settings")
        multimacrosettings.SetFont("s11")
        multimacrocheck := multimacrosettings.AddCheckbox("vMultiMacroMode x25 y25 w100 h40", "Multi macro mode")
        multimacrocheck.Value := IniRead("config.ini", "config", "multiaccountmode") > 0 ? 1 : 0
        multimacrosettings.SetFont("s13 w500")
        multimacrosettings.AddText("x150 y25 w125 h45", "Follower/Leader mode")
        multimacrosettings.SetFont("s16 w500")
        macromode := multimacrosettings.AddDropDownList("vMacroMode x275 y25 w125 h100", ["Leader", "Follower"])
        macromode.Value := multimacrocheck = 0 ? 1 : IniRead("config.ini", "config", "multiaccountmode")
        multimacrosettings.SetFont("s13 w500")
        followers := StrSplit(IniRead("config.ini", "config", "followers"), ",")

        leader := multimacrosettings.AddEdit("vLeader x35 y150 w150 h30", IniRead("config.ini", "config", "leader"))
        follower1 := multimacrosettings.AddEdit("vFollower1 x325 y150 w150 h30", "")
        follower2 := multimacrosettings.AddEdit("vFollower2 x325 y185 w150 h30", "")
        follower3 := multimacrosettings.AddEdit("vFollower3 x325 y220 w150 h30", "")
        multimacrosettings.SetFont("s11 w600")
        multimacrohelp := multimacrosettings.AddButton("x425 y15 w60 h30", "Help")
        for i, k in followers {
            if i = 1 {
                follower1.Text := k
            }
            else if i = 2 {
                follower2.Text := k
            }
            else if i = 3 {
                follower3.Text := k
            }
        }
        multimacrosettings.SetFont("s16 w500")
        multimacrosettings.AddText("x60 y118 w125 h30", "Leader")
        multimacrosettings.AddText("x340 y118 w125 h30", "Followers")

        macromode.Enabled := multimacrocheck.Value
        leader.Enabled := multimacrocheck.Value
        follower1.Enabled := multimacrocheck.Value
        follower2.Enabled := multimacrocheck.Value
        follower3.Enabled := multimacrocheck.Value

        multimacrocheck.OnEvent("Click", MultiMacroEvent)
        leader.OnEvent("Change", MultiMacroEvent)
        follower1.OnEvent("Change", MultiMacroEvent)
        follower2.OnEvent("Change", MultiMacroEvent)
        follower3.OnEvent("Change", MultiMacroEvent)
        macromode.OnEvent("Change", MultiMacroEvent)
        multimacrohelp.OnEvent("Click", MultiMacroHelpF)
        keys2 := { multiaccountmode: "MacroMode", leader: "Leader" }

        MultiMacroEvent(*) {
            followerstring := ""
            for i, k in [follower1, follower2, follower3] {
                if k.Text != "" {
                    followerstring := followerstring = "" ? followerstring . k.Text : followerstring . "," . k.Text
                }
            }
            IniWrite(followerstring, "config.ini", "config", "followers")
            for i, k in keys2.OwnProps() {
                if k = "MacroMode" {
                    if multimacrosettings["MultiMacroMode"].Value = 0 {
                        IniWrite(0, "config.ini", "config", "multiaccountmode")
                    }
                    else {
                        if multimacrosettings["MacroMode"].Value = 0 {
                            multimacrosettings["MacroMode"].Value := 1
                        }
                        IniWrite(multimacrosettings["MacroMode"].Value, "config.ini", "config", "multiaccountmode")
                    }
                    macromode.Enabled := multimacrosettings["MultiMacroMode"].Value
                    leader.Enabled := multimacrosettings["MultiMacroMode"].Value
                    follower1.Enabled := multimacrosettings["MultiMacroMode"].Value
                    follower2.Enabled := multimacrosettings["MultiMacroMode"].Value
                    follower3.Enabled := multimacrosettings["MultiMacroMode"].Value
                    continue
                }
                IniWrite(multimacrosettings[k].Value, "config.ini", "config", i)
            }
        }


        multimacroshow(*) {
            multimacrosettings.Show("w500 h300")
        }

        ButtonF1Start.OnEvent("Click", StartMacro)
        ButtonF3Stop.OnEvent("Click", StopMacro)
        CheckBox1.OnEvent("Click", OnEventHandler)
        Frequency.OnEvent("Change", OnEventHandler)
        Retries.OnEvent("Change", OnEventHandler)
        CheckBox5.OnEvent("Click", OnEventHandler)
        Edit1.OnEvent("Change", OnEventHandler)
        Edit1W.OnEvent("Change", OnEventHandler)
        Edit1A.OnEvent("Change", OnEventHandler)
        Edit2.OnEvent("Change", OnEventHandler)
        GameLoopTimeLimit.OnEvent("Change", OnEventHandler)
        unit1.OnEvent("Click", OnEventHandler)
        unit2.OnEvent("Click", OnEventHandler)
        unit3.OnEvent("Click", OnEventHandler)
        unit4.OnEvent("Click", OnEventHandler)
        unit5.OnEvent("Click", OnEventHandler)
        unit6.OnEvent("Click", OnEventHandler)
        autosummon.OnEvent("Click", OnEventHandler)
        hourlybanners.OnEvent("Click", OnEventHandler)
        maxrolls.OnEvent("Change", OnEventHandler)
        mingems.OnEvent("Change", OnEventHandler)
        keywords.OnEvent("Change", OnEventHandler)
        infinitemap1.OnEvent("Change", OnEventHandler)
        configimport.OnEvent("Click", addOldIniValues)
        myGui.OnEvent('Close', (*) => ExitApp(1))
        vipgamepass.OnEvent("Click", OnEventHandler)
        autosummonhelp.OnEvent("Click", AutoSummonHelpF)
        maxunits.OnEvent("Change", OnEventHandler)
        CheckBox7.OnEvent("Click", OnEventHandler)
        ToeFrequency.OnEvent("Change", OnEventHandler)
        ToeRetries.OnEvent("Change", OnEventHandler)
        ToeVictory.OnEvent("Change", OnEventHandler)
        StatusFreq.OnEvent("Change", OnEventHandler)
        multimacrosettingsbutton.OnEvent("Click", multimacroshow)
        OnExit(TerminateMacro)

        myGui.Title := "Severed 1.0 Pre6.4"
        If (A_EventInfo == 1) {
            Return
        }

        keys := { challengesFrequency: "Frequency", doChallenges: "DoChallenges", webhookMessages: "WebhookMessages",
            privateServerLink: "PrivateServerLink", challengeRetry: "ChalllengeRetry", timeLimit: "TimeLimit",
            unit1: "Unit1", unit2: "Unit2", unit3: "Unit3", unit4: "Unit4", unit5: "Unit5", unit6: "Unit6",
            webhookURL: "WebhookURL", pingID: "PingID", screenshotFrequency: "SsFreq", infiniteMap: "InfiniteMap",
            autosummongemsminimum: "MinGems", autosummonmaxsummons: "MaxRolls", autosummon: "AutoSummon", hourlybanner: "HourlyBanners",
            autosummonunits: "Keywords", hasvip: "HasVip", autosummonmaxunits: "MaxUnits", doToE: "DoToe", toeVictory: "ToEVictory",
            toeRetry: "ToERetry", toeFrequency: "ToEFrequency", statusFrequency: "StatusFreq"
        }

        AutoSummonHelpF(*) {
            MsgBox (
                "Auto summon allows the macro to summon X times if:`n"
                "- current banner has at least 1 matching unit from unit keywords`n"
                "- you have enough gems (> gems minimum parameter)`n `n"
                "Auto summon will be rolling until X times summoned or until you get Y matching units`n"
                "Gems minimum value also means that macro can't go past it, even if 10+ rolls left`n"
                "If you get a unit from keywords, the macro will send a webhook message with ping`n"
                "Max units parameter means how many units you need to get to stop current auto summon session`n"
                "Even if auto summon is disabled it will still send hourly banners unless you disable them`n `n"
                "How to use:`n"
                "- Specify some keywords (unit names) in unit keywords field`n"
                "- Consider that keywords are case-insensitive, spaces are also deleted while code is being executed`n"
                "- All special symbols like !,%^& are also deleted while code is being executed`n"
                "- Use commas to divide keywords, so they will be counted as different words. Or else...`n `n"
                "Keywords examples:`n"
                "beast sorcerer, Ant King,carp, M U S CULA R sorcerer"
            )
        }

        MultiMacroHelpF(*) {
            MsgBox (
                "Multi macro mode allows the macro to act like party mode`n"
                "It has 2 modes, leader and follower modes`n"
                "Leader mode means that it will choose the world, wait for all followers and start a game`n"
                "Follower mode means that it will follow the leader to participate in games`n"
                "Everything was made so you can macro up to 4 accounts at same time, 1 leader and 3 followers`n"
                "To use this you need 2+ PC or you may use Remote Desktop (rdp wrapper on github)"
                "Note: currently only does infinite mode`n `n"
                "Leader setup:`n"
                " - Specify at least 1 follower's nickname (optional: roblox nickname, not username)`n"
                " - Start the macro`n `n"
                "Follower setup:`n"
                " - Specify your leader's nickname (not username)`n"
                " - Start the macro`n `n"
                "Optional note: all your macros must have the same game loop time limit, or else your macro can break"
            )
        }

        OnEventHandler(*) {
            for i, k in keys.OwnProps() {
                if k = "AutoSummon" and myGui[k].Value = 1 {
                    if StrReplace(myGui["Keywords"].Value, " ", "") = "" {
                        myGui[k].Value := 0
                        MsgBox "Specify at least 1 keyword (unit's name)"
                    }
                }
                if k = "MinGems" {
                    myGui["MinGemsValue"].Value := myGui[k].Value
                    IniWrite(myGui[k].Value, "config.ini", "config", i)
                }
                if k = "WebhookMessages" {
                    valid := validateWebhookLink(myGui["webhookURL"].Value)
                    if valid {
                        IniWrite(myGui[k].Value, "config.ini", "config", i)
                    }
                    else {
                        if myGui["WebhookMessages"].Value = 0 and myGui["WebhookURL"].Value = "" {
                            continue
                        }
                        IniWrite("", "config.ini", "config", "webhookURL")
                        myGui["webhookURL"].Value := ""
                        CheckBox5.Value := 0
                        IniWrite(0, "config.ini", "config", "webhookMessages")
                        MsgBox (
                            "Invalid webhook URL"
                        )
                    }
                }
                if k = "WebhookURL" {
                    valid := validateWebhookLink(myGui[k].Value)
                    if valid {
                        IniWrite(myGui[k].Value, "config.ini", "config", i)
                    }
                    else {
                        if myGui["WebhookMessages"].Value = 0 and myGui["WebhookURL"].Value = "" {
                            continue
                        }
                        IniWrite("", "config.ini", "config", "webhookURL")
                        myGui["webhookURL"].Value := ""
                        CheckBox5.Value := 0
                        IniWrite(0, "config.ini", "config", "webhookMessages")
                        MsgBox (
                            "Invalid webhook URL"
                        )
                        continue
                    }
                }
                if k = "PingID" {
                    if not myGui[k].Value {
                        IniWrite(0, "config.ini", "config", i)
                        myGui[k].Value := 0
                        continue
                    }

                }
                if k = "PrivateServerLink" {
                    if myGui[k].Value {
                        if not RegExMatch(myGui[k].Value, "(?<=privateServerLinkCode=)(.*)", &serverId) {
                            myGui[k].Value := ""
                            IniWrite("", "config.ini", "config", i)
                            IniWrite(0, "config.ini", "config", "privateServerLinkCode")
                            MsgBox (
                                "Private server link must have privateServerLinkCode link format `n"
                                "To get that do next steps:`n"
                                "1. Copy your share link in private server's properties`n"
                                "2. Paste it into your browser search bar and press Enter`n"
                                "3. Wait until it's fully loaded`n"
                                "4. Copy a new link from the search bar`n"
                                "5. Paste it in private server link field`n"
                            )
                            continue
                        }
                        IniWrite(myGui[k].Value, "config.ini", "config", i)
                        IniWrite(serverId[1], "config.ini", "config", "privateServerLinkCode")
                        continue
                    }

                }
                IniWrite(myGui[k].Value, "config.ini", "config", i)
            }
        }

        return myGui
    }
    catch Error {
        MsgBox (
            "New values are missed in your config.`n"
            "To add them select your current config.`n"
            "Note: you need to have a new config_default.ini for this"
        )
        addOldIniValues()
    }
}

; roundify in case someones on w10

disconnects := 0
reconnects := 0

canStart := true ; checks if you can start the macro
macroStarted := false ; macro started check

lobbydetected := false ; checks if lobby was detected
gamedetected := false ; checks if a game was detected

; Returns time in minutes:seconds format (for example 00:01 or 15:04)
; time parameter is seconds
; doesn't work with negative values (will always return 00:00)
FormatTimer(time) {
    if time < 0 {
        return "00:00"
    }
    return String((Mod(time, 60) = 0 ? time // 60 ":00" : (time > 60 ? time // 60 ":" (Mod(time, 60) < 10 ? "0" Mod(time, 10) : Mod(time, 60)) : "00:" (Mod(time, 60) < 10 ? "0" Mod(time, 10) : Mod(time, 60)))))
}

; Starts macro
StartMacro(*)
{
    if not canStart {
        return
    }
    if macroStarted {
        return
    }
    global maxunits
    global gdiptoken
    gdiptoken := Gdip_Startup()
    global autosummon
    global hourlybanners
    autosummon := IniRead("config.ini", "config", "autosummon")
    hourlybanners := IniRead("config.ini", "config", "hourlybanner")
    global units
    global gemsmin
    global summonmax
    global hasvip
    global unitsstring
    unitsstring := IniRead("config.ini", "config", "autosummonunits")
    units := []
    for i in StrSplit(unitsstring, ",") {
        units.Push RegExReplace(StrReplace(StrLower(i), " ", ""), "[^A-Za-z0-9]")
    }

    maxunits := IniRead("config.ini", "config", "autosummonmaxunits")
    gemsmin := IniRead("config.ini", "config", "autosummongemsminimum")
    summonmax := IniRead("config.ini", "config", "autosummonmaxsummons")
    hasvip := IniRead("config.ini", "config", "hasvip")

    global infinitemap
    global maps
    infinitemap := IniRead("config.ini", "config", "infiniteMap")
    maps := { 1: "lib\images\windmillvillage.png", 2: "lib\images\haunted_city.png", 3: "lib\images\cursed_academy.png", 4: "lib\images\blue_planet.png", 5: "lib\images\underwater_temple.png", 6: "lib\images\swordsman_dojo.png", 7: "lib\images\snowy_woods.png", 8: "lib\images\crystal_cave.png" }
    mapnames := ["Windmill Village", "Haunted City", "Cursed Academy", "Blue Planet", "Underwater Temple", "Swordsman Dojo", "Snowy Woods", "Crystal Cave"]


    global pingID
    global webhookURL
    global webhookMessages
    global statusFreq
    statusFreq := IniRead("config.ini", "config", "statusFrequency")
    pingID := IniRead("config.ini", "config", "pingID")
    webhookURL := IniRead("config.ini", "config", "webhookURL")
    webhookMessages := IniRead("config.ini", "config", "webhookMessages")
    challengedate := IniRead("config.ini", "config", "challengeDate")
    canChallenge := IniRead("config.ini", "config", "canChallenge")

    challenge1 := IniRead("config.ini", "config", "challenge1")
    challenge2 := IniRead("config.ini", "config", "challenge2")
    challenge3 := IniRead("config.ini", "config", "challenge3")

    currentchallenge := 0
    global challengeRetries := IniRead("config.ini", "config", "challengeRetry")
    global gameloopTimeLimit := IniRead("config.ini", "config", "timeLimit")
    global doChallenges := IniRead("config.ini", "config", "doChallenges")
    global challengesFrequency := IniRead("config.ini", "config", "challengesFrequency")
    global privateservercode := IniRead("config.ini", "config", "privateServerLinkCode")
    global gamereconnectlinkps := "roblox://placeID=17017769292&linkCode="
    global gamereconnectlink := "roblox://placeID=17017769292"
    challenge1retry := 1 - challengeRetries
    challenge2retry := 1 - challengeRetries
    challenge3retry := 1 - challengeRetries
    global myGui
    global canStart
    global macroStarted

    global toe
    global toemaxretries
    global toemaxwins
    toe := IniRead("config.ini", "config", "doToE")
    toemaxretries := IniRead("config.ini", "config", "toeRetry")
    toemaxwins := IniRead("config.ini", "config", "toeVictory")
    cantoe := IniRead("config.ini", "config", "canToE")
    toedate := IniRead("config.ini", "config", "toeDate")
    toefreq := IniRead("config.ini", "config", "toeFrequency")

    summoncheckeddate := IniRead("config.ini", "config", "shopcheckeddate")
    webhookPing := pingID ? "<@" pingID ">" : ""
    global webhookPing
    canStart := false
    macroStarted := true
    challengesin := "Now!"
    date := FormatTime(A_Now, "[HH:mm:ss]")
    challenge12 := challenge1 ? "Completed" : "Unfinished"
    challenge22 := challenge2 ? "Completed" : "Unfinished"
    challenge32 := challenge3 ? "Completed" : "Unfinished"
    date := FormatTime(A_Now, "[HH:mm:ss]")
    data :=
        (LTrim Join
            '{
        "content": "",
        "embeds": [{
            "title": "' date '", "type": "rich", "description": "# Status: Started",
            "image": {}, "color": 6812258,
            "fields": []
                    }
                ]
            }
            '
        )
    webhookPost(data, {})

    myGui.Title := "Working - Severed 1.0 Pre6.4"
    if WinExist("ahk_exe" "RobloxPlayerBeta.exe") {
        WinActivate("ahk_exe" "RobloxPlayerBeta.exe")
        Sleep(1000)
        WinGetClientPos &x, &y, &w, &h, "ahk_exe" "RobloxPlayerBeta.exe"
        if h != 1080 {
            Send "{F11}"
        }
    }

    global gameloopTimeLimit
    global workingscripts
    global lobbydetected
    global gamedetected
    global loopFlag
    global currentchallenge
    global leader
    global followers
    loopFlag := true
    failcounter := 0
    victorycounter := 0

    multiaccountmode := IniRead("config.ini", "config", "multiaccountmode")
    leader := StrLower(IniRead("config.ini", "config", "leader"))
    followers := StrSplit(StrReplace(StrLower(IniRead("config.ini", "config", "followers")), " ", ""), ",")

    myGui.Minimize()
    While loopFlag ; i need to find a way to stop the loop halfway through
    {

        reconnected := false
        lobbydetected := false ; must be always false at the beginning to prevent immediately walk
        gamedetected := false ; also that means that a loop has started again
        global challengedate
        global canChallenge
        global doChallenges

        global challenge1
        global challenge2
        global challenge3

        global challenge1retry
        global challenge2retry
        global challenge3retry

        disconnected := disconnectCheck()
        if disconnected {
            tryReconnect()
        }
        Sleep(1000)
        Loop 20 {

            if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\shop.png") {
                ; if it firstly sees shop button
                lobbydetected := true
                break
            }
            else {
                if disconnectCheck() {
                    tryReconnect()
                    reconnected := true
                    break
                }
                Sleep(1500)
            }

        }
        if reconnected = true {
            continue
        }
        if lobbydetected = false {
            ; restarts the loop if lobby wasn't detected
            tryReconnect()
            continue
        }

        if PixelSearch(&x, &y, 81, 25, 81, 25, "0xFFFFFF") {
            MouseMove x, y, 5
            Sleep(300)
            Click
            MouseMove 960, 540, 5
        }

        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\x.png") {
            ; if sees update logs close button then lobby is detected, then it click on that button to close it
            MouseMove x, y, 5
            Sleep(50)
            Click
            Sleep(50)
            MouseMove x, y - 50 5
            Sleep(50)
        }

        date := FormatTime(A_Now, "[HH:mm:ss]")
        ; lobby detected webhook message json data
        Gdip_SaveBitmapToFile(a := Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
        Gdip_DisposeImage(a)
        data :=
            (LTrim Join
                '{
            "content": "",
            "embeds": [{
                    "title": "' date '", "type": "rich", "description": "# Status: Lobby detected",
                    "image": {"url": "attachment://ss.png"}, "color": 11394479,
                    "fields": []
                }
            ]
        }
            '
            )
        webhookPost(data, { 1: "ss.png" })

        ssDate := IniRead("config.ini", "config", "screenshotDate")
        ssFreq := IniRead("config.ini", "config", "screenshotFrequency")

        if DateDiff(A_Now, DateAdd(ssDate, ssFreq, "Minutes"), "Minutes") >= 0 {
            IniWrite(A_Now, "config.ini", "config", "screenshotDate")
            date := FormatTime(A_Now, "[HH:mm:ss]")
            ; gems webhook message json data
            data2 :=
                (LTrim Join
                    '{
                "content": "' webhookPing '",
                "embeds": [{
                        "title": "' date '", "type": "rich", "description": "# Gems / Inventory \r ## - Gems",
                        "image": {"url": "attachment://gemss.png"}, "color": 14466806,
                        "fields": []
                    },{
                        "title": "", "type": "rich", "description": "## - Inventory \r \r ### Next screenshots are coming in ' ssFreq ' minutes",
                        "image": {"url": "attachment://inv.png"}, "color": 9427318,
                        "fields": []
                    }
                ]
            }
                '
                )
            ; inventory webhook message json data

            if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\items.png") {
                MouseMove x, y, 5
                Sleep(50)
                Click
                Sleep(300)
                Gdip_SaveBitmapToFile(a := Gdip_BitmapFromScreen("400|269|750|527"), "inv.png")
                Gdip_SaveBitmapToFile(b := Gdip_BitmapFromScreen("713|890|500|40"), "gemss.png")
                Gdip_DisposeImage(a)
                Gdip_DisposeImage(b)
                webhookPost(data2, { 2: "inv.png", 1: "gemss.png" })
                if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\x_inv.png") {
                    MouseMove x, y, 5
                    Sleep(50)
                    Click
                    Sleep(50)
                    MouseMove x, y - 50, 5
                }
            }
        }
        Sleep 250
        AlignPlayer()
        Sleep 2000

        if DateDiff(A_YYYY A_MM A_DD A_Hour A_Min, DateAdd(challengedate, challengesFrequency, "Minutes"), "Minutes") >= 0 and canChallenge = 0 { ; challenge frequency is minutes
            IniWrite(1, "config.ini", "config", "canChallenge")
            canChallenge := 1
            challenge1 := 0
            challenge1retry := 1 - challengeRetries
            challenge2 := 0
            challenge2retry := 1 - challengeRetries
            challenge3 := 0
            challenge3retry := 1 - challengeRetries
            challengedate := A_YYYY A_MM A_DD A_Hour A_Min
            IniWrite(0, "config.ini", "config", "challenge1")
            IniWrite(0, "config.ini", "config", "challenge2")
            IniWrite(0, "config.ini", "config", "challenge3")
            IniWrite(challengedate, "config.ini", "config", "challengeDate")
            ; resetting all challenges
        }

        if DateDiff(A_YYYY A_MM A_DD A_Hour A_Min, DateAdd(toedate, toefreq, "Minutes"), "Minutes") >= 0 and cantoe = 0 { ; challenge frequency is minutes
            IniWrite(1, "config.ini", "config", "canToe")
            cantoe := 1
            failcounter := 0
            victorycounter := 0
            toedate := A_YYYY A_MM A_DD A_Hour A_Min
            IniWrite(toedate, "config.ini", "config", "toeDate")
            ; resetting all challenges
        }

        if challenge1retry = 2 {
            challenge1 := 1
            IniWrite(1, "config.ini", "config", "challenge1")
        }
        if challenge2retry = 2 {
            challenge2 := 1
            IniWrite(1, "config.ini", "config", "challenge2")
        }
        if challenge3retry = 2 {
            challenge3 := 1
            IniWrite(1, "config.ini", "config", "challenge3")
        }

        if cantoe = 1 and (failcounter > toemaxretries or victorycounter > toemaxwins) {
            IniWrite(0, "config.ini", "config", "cantoe")
            cantoe := 0
            toedate := A_YYYY A_MM A_DD A_Hour A_Min
            IniWrite(toedate, "config.ini", "config", "toeDate")
        }

        if (autosummon or hourlybanners) and DateDiff(A_YYYY A_MM A_DD A_Hour, summoncheckeddate, "Hours") >= 1 {
            summoncheckeddate := A_YYYY A_MM A_DD A_Hour
            IniWrite(A_YYYY A_MM A_DD A_Hour, "config.ini", "config", "shopcheckeddate")
            date := FormatTime(A_Now, "[HH:mm:ss]")
            data :=
                (LTrim Join
                    '{
            "content": "",
            "embeds": [{
                    "title": "' date '", "type": "rich", "description": "# Status: Going to Summon",
                    "image": {}, "color": 8487813
                }
            ]
        }
            '
                )
            webhookPost(data, {})
            WalkToSummon()
            summonRun()
            tryReconnect()
            continue
        }

        if multiaccountmode {
            date := FormatTime(A_Now, "[HH:mm:ss]")
            data :=
                (LTrim Join
                    '{
                "content": "",
                "embeds": [{
                        "title": "' date '", "type": "rich", "description": "# Multi macro: Going to Story (infinite mode)",
                        "image": {}, "color": 8487813,
                "fields": []
                    }
                ]
            }
                '
                )
            webhookPost(data, {})
            WalkToStory()
            Sleep 100
            EnterStoryPortal()
            gameStarted := false
            if multiaccountmode = 1 {
                Loop 10 {
                    ; trying to start a game
                    gameStarted := TryGameStartLeader()
                    if gameStarted = true {
                        data :=
                            (LTrim Join
                                '{
                                        "content": "",
                                        "embeds": [{
                                                "title": "' date '", "type": "rich", "description": "# Multi macro: All followers joined",
                                                "image": {}, "color": 8487813
                                            }
                                        ]
                                    }
                                        '
                            )
                        webhookPost(data, {})
                        break
                    }
                }
            }
            else if multiaccountmode = 2 {
                loop 10 {
                    gameStarted := TryLeaderJoin()
                    if gameStarted = 2 {
                        gameStarted := false
                        break
                    }
                    if gameStarted {
                        break
                    }
                }
            }
            if gameStarted = false {
                tryReconnect()
                continue
            }
            gamedetected := false
            Loop 60 {
                if not gamedetected {
                    ; trying to detect infinite sign
                    abc := OCR.FromRect(0, 1000, 500, 80, "en", 1)
                    date := FormatTime(A_Now, "[HH:mm:ss]")
                    if Mod(A_Index, 3) = 0 {
                        data :=
                            (LTrim Join
                                '{
                                    "content": "",
                                    "embeds": [{
                                            "title": "' date '", "type": "rich", "description": "# Multi macro: Detecting a game ' A_Index // 3 ' \r debug: ' abc.Text '",
                                            "image": {}, "color": 8487813
                                        }
                                    ]
                                }
                                    '
                            )
                        webhookPost(data, {})
                    }
                    if RegExMatch(abc.Text, "i)Infinite") {
                        gamedetected := true
                        break
                    }
                    else {
                        Sleep(2000)
                    }
                }
            }
            if not gamedetected {
                ; if game wasn't detected
                tryReconnect()
                continue
            }
            ; if game was detected the macro starts a game loop
            gameGoing := true
            if PixelSearch(&x, &y, 81, 25, 81, 25, "0xFFFFFF") {
                MouseMove x, y, 5
                Sleep(300)
                Click
                MouseMove 960, 540, 5
            }


            LookDown()
            Run 'gameloop.ahk', "lib", , &gamelooppid

            global gameloopPIDvar
            gameloopPIDvar := gamelooppid
            gameStartedAt := A_Now
            gameEndsAt := DateAdd(gameStartedAt, gameloopTimeLimit, "Minutes")
            statusmessagedate := DateAdd(gameStartedAt, -9, "Seconds")
            while gameGoing = true {
                Loop 2 {
                    if DateDiff(A_Now, statusmessagedate, "Seconds") >= 0 {
                        statusmessagedate := DateAdd(A_Now, statusFreq * 60, "Seconds")
                        Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
                        data2 :=
                            (LTrim Join
                                '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Multi macro: Doing ' mapnames[infinitemap] ' infinite mode \r ### Time left - ' FormatTimer(DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                        "image": {"url": "attachment://ss.png"}, "color": 8487813,
                                "fields": []
                                    }
                                ]
                            }
                                '
                            )
                        webhookPost(data2, { 1: "ss.png" })
                    }
                    ; if counter = 0 it will end the game
                    if DateDiff(gameEndsAt, A_Now, "Seconds") <= 0 {
                        CloseSubScripts()
                        gameloopPIDvar := 0
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                        data2 :=
                            (LTrim Join
                                '{
                            "content": "",
                            "embeds": [{
                                    "title": "' date '", "type": "rich", "description": "# Multi macro: About to leave, deleting units \r ### Time spent - ' FormatTimer(gameloopTimeLimit * 60 - DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                    "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                    "fields": []
                                }
                            ]
                        }
                            '
                            )
                        webhookPost(data2, { 1: "ss.png" })
                        for i in range(5) {
                            Sleep 250
                            Row1L(i, 1)
                            Sleep 250
                            Row1L(i, -1)
                        }
                        while true {
                            if not CheckForDeath() {
                                break
                            }
                            Sleep 2000
                        }
                        gameGoing := false
                        break
                    }
                    Sleep(2000)
                }
                if gameGoing = false {
                    break
                }
                ; if death was detected it will end the game and go to lobby, then loop starts again
                deathcheck := CheckForDeath()
                gameGoing := deathcheck
                if not deathcheck {
                    date := FormatTime(A_Now, "[HH:mm:ss]")
                    data2 :=
                        (LTrim Join
                            '{
                            "content": "",
                            "embeds": [{
                                    "title": "' date '", "type": "rich", "description": "# Multi macro: Died \r ### Time spent - ' FormatTimer(gameloopTimeLimit * 60 - DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                    "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                    "fields": []
                                }
                            ]
                        }
                            '
                        )
                    webhookPost(data2, { 1: "ss.png" })
                    break
                }
                reconnect := false
                disconnected := disconnectCheck()
                if disconnected {
                    CloseSubScripts()
                    tryReconnect()
                    reconnect := true
                    gameGoing := false
                    break
                }

            }

            if reconnect {
                lobbydetected := false
                gamedetected := false
                continue
            }


            if not gameGoing {
                lobbydetected := false
                gamedetected := false
                ; after game ended
                disconnected := disconnectCheck()
                if disconnected {
                    tryReconnect()
                }
                continue
            }
        }

        if toe and cantoe and failcounter <= toemaxretries {
            Send "{w down}"
            Send "{a down}"
            Sleep 1500
            Send "{w up}"
            Send "{a up}"
            Sleep 250
            Send "{d down}"
            Sleep 250
            Send "{d up}"
            Sleep 600
            Send "{e 1}"
            Sleep 2500
            floorfound := false
            loop 5 {
                a := OCR.FromRect(549, 362, 210, 60, "en", 2)
                if a.Text != "" {
                    RegExMatch(a.Text, "i)floor (.*)", &b)
                    try {
                        currentfloor := Number(b[1])
                    }
                    catch {
                        currentfloor := "unknown?"
                    }
                    data :=
                        (LTrim Join
                            '{
                        "content": "",
                        "embeds": [{
                                "title": "' date '", "type": "rich", "description": "# Status: Going to Tower of Eternity Floor ' currentfloor '",
                                "image": {}, "color": 8487813
                            }
                        ]
                    }
                        '
                        )
                    webhookPost(data, {})
                    floorfound := true
                    break
                }
                else {
                    Send "{d down}"
                    Sleep 50
                    Send "{d up}"
                    Send "{e 1}"
                    Sleep 2500
                    continue
                }
            }
            if not floorfound {
                failcounter += 1
                tryReconnect()
                continue
            }
            gameStarted := TryToEStart()
            if not gameStarted {
                tryReconnect()
                continue
            }
            if gameStarted {
                gamedetected := false
                Loop 240 {
                    if not gamedetected {
                        ; trying to detect challenge sign
                        abc := OCR.FromRect(0, 1000, 500, 80, "en", 8)
                        if RegExMatch(abc.Text, "i)Tow") {
                            gamedetected := true
                            break
                        }
                        else {
                            Sleep(500)
                        }
                    }
                }
                if not gamedetected {
                    ; if game wasn't detected
                    ; this will break the whole thing for a while (until somebody makes reconnect feature)
                    tryReconnect()
                    continue
                }
                newGame := true
                gameGoing := true
                if PixelSearch(&x, &y, 81, 25, 81, 25, "0xFFFFFF") {
                    MouseMove x, y, 5
                    Sleep(300)
                    Click
                    MouseMove 960, 540, 5
                }
                global gameloopPIDvar
                while gameGoing {
                    if newGame {
                        AlignPlayerToE()
                        Sleep 1000
                        LookDown()
                    }
                    Run 'gameloop.ahk', "lib", , &gamelooppid
                    gameloopPIDvar := gamelooppid

                    newGame := false
                    floorGoing := true
                    gameStartedAt := A_Now
                    statusmessagedate := DateAdd(A_Now, -9, "Seconds")
                    gameEndsAt := DateAdd(gameStartedAt, gameloopTimeLimit, "Minutes")
                    while floorGoing {
                        loop 2 {
                            if DateDiff(A_Now, statusmessagedate, "Seconds") >= 0 {
                                if DateDiff(A_Now, challengedate, "Minutes") < 0 {
                                    challengesin := DateDiff(DateAdd(challengedate, challengesFrequency, "Minutes"), A_Now, "Minutes")
                                }
                                else {
                                    challengesin := "Now!"
                                }
                                statusmessagedate := DateAdd(A_Now, statusFreq * 60, "Seconds")
                                Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                                date := FormatTime(A_Now, "[HH:mm:ss]")
                                challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
                                data2 :=
                                    (LTrim Join
                                        '{
                                        "content": "",
                                        "embeds": [{
                                                "title": "' date '", "type": "rich", "description": "# Status: Doing Tower of Eternity Floor ' currentfloor ' \r ### Time left - ' FormatTimer(DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                                "image": {"url": "attachment://ss.png"}, "color": 8487813,
                                        "fields": []
                                            }
                                        ]
                                    }
                                        '
                                    )
                                webhookPost(data2, { 1: "ss.png" })
                            }
                            if DateDiff(gameEndsAt, A_Now, "Seconds") <= 0 and gameGoing = true {
                                CloseSubScripts()
                                gameloopPIDvar := 0
                                Sleep(1000)
                                MouseMove 121, 7, 5
                                Sleep(300)
                                Click
                                Sleep(300)
                                MouseMove 164, 129, 5
                                Sleep(300)
                                Click
                                Sleep(300)
                                MouseMove 865, 633, 5
                                Sleep(300)
                                Click
                                gameGoing := false
                                floorGoing := false
                                break
                            }
                            Sleep 2000
                        }
                        if floorGoing = false {
                            break
                        }
                        ; if death was detected it will end the game and go to lobby, then loop starts again
                        wincheck := CheckForToEWin()
                        if wincheck = 3 {
                            victorycounter += 1
                            failcounter := 0
                            floorGoing := false
                            gameGoing := false
                            reconnect := true
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            data2 :=
                                (LTrim Join
                                    '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Victory! \r### - Tower of Eternity Floor ' currentfloor '\r### Note: captcha failed",
                                        "image": {"url": "attachment://ss.png"}, "color": 6815586,
                                        "fields": []
                                    }
                                ]
                            }
                                '
                                )
                            webhookPost(data2, { 1: "ss.png" })
                            try {
                                currentfloor += 1
                            }
                            tryReconnect()
                            break
                        }
                        else if wincheck = 4 {
                            failcounter += 1
                            gameGoing := false
                            floorGoing := false
                            reconnect := true
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            data2 :=
                                (LTrim Join
                                    '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Defeat! \r### - Tower of Eternity Floor ' currentfloor ' \r### - Retries left - ' toemaxretries - failcounter + 1 ' \r### Note: captcha failed",
                                        "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                        "fields": []
                                    }
                                ]
                            }
                                '
                                )
                            webhookPost(data2, { 1: "ss.png" })
                            tryReconnect()
                            break
                        }
                        else if wincheck != 2 {
                            if wincheck = 0 {
                                victorycounter += 1
                                failcounter := 0
                                floorGoing := false
                                date := FormatTime(A_Now, "[HH:mm:ss]")
                                data2 :=
                                    (LTrim Join
                                        '{
                                        "content": "",
                                        "embeds": [{
                                            "title": "' date '", "type": "rich", "description": "# Status: Victory! \r### - Tower of Eternity Floor ' currentfloor '",
                                            "image": {"url": "attachment://ss.png"}, "color": 6815586,
                                            "fields": []
                                        }
                                    ]
                                }
                                '
                                    )
                                webhookPost(data2, { 1: "ss.png" })
                                try {
                                    currentfloor += 1
                                }
                                break
                            }
                            else if wincheck = 1 {
                                failcounter += 1
                                gameGoing := false
                                floorGoing := false
                                date := FormatTime(A_Now, "[HH:mm:ss]")
                                data2 :=
                                    (LTrim Join
                                        '{
                                    "content": "",
                                    "embeds": [{
                                            "title": "' date '", "type": "rich", "description": "# Status: Defeat \r### - Tower of Eternity Floor ' currentfloor ' \r### - Retries left - ' toemaxretries - failcounter + 1 '",
                                            "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                            "fields": []
                                        }
                                    ]
                                }
                                    '
                                    )
                                webhookPost(data2, { 1: "ss.png" })
                                break
                            }
                        }
                        reconnect := false
                        disconnected := disconnectCheck()
                        if disconnected {
                            CloseSubScripts()
                            tryReconnect()
                            reconnect := true
                            gameGoing := false
                            break
                        }
                        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\submit.png") {
                            CloseSubScripts()
                            doCaptcha()
                            floorGoing := false
                            gameGoing := false
                            tryReconnect()
                        }
                        if not floorGoing {
                            break
                        }
                    }
                    if not gameGoing {
                        break
                    }
                }
                if reconnect = true {
                    lobbydetected := false
                    gamedetected := false
                    continue
                }
                if gameGoing = false {
                    lobbydetected := false
                    gamedetected := false
                    ; after game ended
                    disconnected := disconnectCheck()
                    if disconnected
                    {
                        tryReconnect()
                    }
                    continue
                }
            }
        }

        if challenge1 = 1 and challenge2 = 1 and challenge3 = 1 and canChallenge = 1 {
            IniWrite(0, "config.ini", "config", "canChallenge")
            canChallenge := 0
            challengedate := A_YYYY A_MM A_DD A_Hour A_Min
            IniWrite(challengedate, "config.ini", "config", "challengeDate")
        }
        ; if all challenges are completed then disable challenges until X minutes passed
        ; also changing saved challenge date

        if canChallenge and doChallenges = 1 {
            challengesin := "Now!"
            date := FormatTime(A_Now, "[HH:mm:ss]")
            challenge12 := challenge1 ? "Completed" : "Unfinished"
            challenge22 := challenge2 ? "Completed" : "Unfinished"
            challenge32 := challenge3 ? "Completed" : "Unfinished"
            data :=
                (LTrim Join
                    '{
                "content": "",
                "embeds": [{
                        "title": "' date '", "type": "rich", "description": "# Status: Going to challenges",
                        "image": {}, "color": 8487813,
                        "fields": [{"name": "Challenge 1", "value": "' challenge12 '", "inline": true},
                            {"name": "Challenge 2", "value": "' challenge22 '", "inline": true},
                            {"name": "Challenge 3", "value": "' challenge32 '", "inline": true}]
                    }
                ]
            }
                '
                )
            webhookPost(data, {})
            WalkToChallenge()
            gameStarted := false
            for i in [1, 2, 3] {
                ; checking every challenge
                key := ""
                currentchallenge := i
                if i = 1 {
                    challenge := &challenge1
                    challengeretry := &challenge1retry
                    key := "challenge1"
                }
                else if i = 2 {
                    challenge := &challenge2
                    challengeretry := &challenge2retry
                    key := "challenge2"
                }
                else {
                    challenge := &challenge3
                    challengeretry := &challenge3retry
                    key := "challenge3"
                }

                if i != 1 {
                    Send "{d down}"
                    Sleep(1500)
                    Send "{d up}"
                }
                ; going further

                if %challenge% = 0 and %challengeretry% < 2 {

                    ; trying to start the game if challenge isn't completed and macro can retry
                    gameStartedCheck := TryChallengeStart()
                    gameStarted := gameStartedCheck
                    if gameStarted {
                        break
                    }

                }
                if gameStarted {
                    break
                }
                if not gameStarted and i != 3 and %challenge% = 0 {
                    left := selectionleavechall()
                    %challenge% := 1
                    IniWrite(1, "config.ini", "config", key)
                    if not left {
                        Send "{s down}"
                        Sleep(150)
                        Send "{s up}"
                    }
                    continue
                }
                if not gameStarted and i = 3 and %challenge% = 0 {
                    left := selectionleavechall()
                    %challenge% := 1
                    IniWrite(1, "config.ini", "config", key)
                }
            }
            if gameStarted = false {
                tryReconnect()
                continue
            }

            if gameStarted = true {
                gamedetected := false

                Loop 500 {
                    if not gamedetected {
                        ; trying to detect challenge sign
                        abc := OCR.FromRect(0, 1000, 500, 80, "en", 8)
                        if RegExMatch(abc.Text, "i)Chall") {
                            gamedetected := true
                            break
                        }
                        else {
                            Sleep(100)
                        }
                    }
                }
                if not gamedetected {
                    ; if game wasn't detected
                    ; this will break the whole thing for a while (until somebody makes reconnect feature)
                    tryReconnect()
                    continue
                }
                ; if game was detected the macro starts a game loop
                gameGoing := true
                if PixelSearch(&x, &y, 81, 25, 81, 25, "0xFFFFFF") {
                    MouseMove x, y, 5
                    Sleep(300)
                    Click
                    MouseMove 960, 540, 5
                }

                LookDown()
                Run 'gameloop.ahk', "lib", , &gamelooppid

                global gameloopPIDvar
                gameloopPIDvar := gamelooppid
                ; edit config.ahk2 to change max game loop time

                gameStartedAt := A_Now
                gameEndsAt := DateAdd(gameStartedAt, gameloopTimeLimit, "Minutes")
                wave := 1
                statusmessagedate := DateAdd(A_Now, -9, "Seconds")
                while gameGoing = true {
                    ; if counter = counter limit it will end the game
                    Loop 2 {
                        if DateDiff(A_Now, statusmessagedate, "Seconds") >= 0 {
                            statusmessagedate := DateAdd(A_Now, statusFreq * 60, "Seconds")
                            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            data2 :=
                                (LTrim Join
                                    '{
                                    "content": "",
                                    "embeds": [{
                                    "title": "' date '", "type": "rich", "description": "# Status: Doing Challenge ' currentchallenge ' \r ### Time left - ' FormatTimer(DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                    "image": {"url": "attachment://ss.png"}, "color": 8487813,
                                    "fields": []
                                        }
                                    ]
                                }
                                    '
                                )
                            webhookPost(data2, { 1: "ss.png" })
                        }
                        if DateDiff(gameEndsAt, A_Now, "Seconds") <= 0 and gameGoing = true {
                            CloseSubScripts()
                            gameloopPIDvar := 0
                            Sleep(1000)
                            MouseMove 121, 7, 5
                            Sleep(300)
                            Click
                            Sleep(300)
                            MouseMove 164, 129, 5
                            Sleep(300)
                            Click
                            Sleep(300)
                            MouseMove 865, 633, 5
                            Sleep(300)
                            Click
                            gameGoing := false
                            break
                        }
                        reconnect := false
                        if canChallenge or DateDiff(A_YYYY A_MM A_DD A_Hour A_Min, DateAdd(challengedate, challengesFrequency, "Minutes"), "Minutes") >= 0 {
                            challengesin := "Now!"
                        }
                        else {
                            challengesin := DateDiff(DateAdd(challengedate, challengesFrequency, "Minutes"), A_Now, "Minutes")
                        }
                        Sleep(2000)
                    }
                    if gameGoing = false {
                        break
                    }
                    ; if death was detected it will end the game and go to lobby, then loop starts again
                    wincheck := CheckForWin()
                    if wincheck != 2 {
                        if wincheck = 0 {
                            %challenge% := 1
                            IniWrite(1, "config.ini", "config", key)
                            gameGoing := false
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            data2 :=
                                (LTrim Join
                                    '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Victory! ",
                                        "image": {"url": "attachment://ss.png"}, "color": 6815586,
                                        "fields": []
                                    }
                                ]
                            }
                                '
                                )
                            webhookPost(data2, { 1: "ss.png" })
                            break
                        }
                        else if wincheck = 1 {
                            %challengeretry% += 1
                            gameGoing := false
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            data2 :=
                                (LTrim Join
                                    '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Defeat",
                                        "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                        "fields": []
                                    }
                                ]
                            }
                                '
                                )
                            webhookPost(data2, { 1: "ss.png" })
                            break
                        }
                    }
                    disconnected := disconnectCheck()
                    if disconnected {
                        CloseSubScripts()
                        tryReconnect()
                        reconnect := true
                        gameGoing := false
                        break
                    }
                }
            }
            if reconnect {
                lobbydetected := false
                gamedetected := false
                continue
            }
            if not gameGoing {
                lobbydetected := false
                gamedetected := false
                ; after game ended
                disconnected := disconnectCheck()
                if disconnected {
                {
                    tryReconnect()
                }
                continue
                }
            }
        }
        if not canChallenge or doChallenges = 0 {
            if DateDiff(A_Now, challengedate, "Minutes") < 0 or canChallenge = 0 {
                challengesin := DateDiff(DateAdd(challengedate, challengesFrequency, "Minutes"), A_Now, "Minutes")
            }
            else {
                challengesin := "Now!"
            }
            date := FormatTime(A_Now, "[HH:mm:ss]")
            challenge12 := challenge1 ? "Completed" : "Unfinished"
            challenge22 := challenge2 ? "Completed" : "Unfinished"
            challenge32 := challenge3 ? "Completed" : "Unfinished"
            challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
            data :=
                (LTrim Join
                    '{
                "content": "",
                "embeds": [{
                        "title": "' date '", "type": "rich", "description": "# Status: Going to Story (infinite mode) \r ### Challenges in - ' challengesin2 '",
                        "image": {}, "color": 8487813,
                "fields": [{"name": "Challenge 1", "value": "' challenge12 '", "inline": true},
                            {"name": "Challenge 2", "value": "' challenge22 '", "inline": true},
                            {"name": "Challenge 3", "value": "' challenge32 '", "inline": true}]
                    }
                ]
            }
                '
                )
            webhookPost(data, {})
            WalkToStory()
            Sleep 100
            EnterStoryPortal()
            gameStarted := false
            Loop 5 {
                ; trying to start the game
                gameStartedCheck := TryGameStart()
                gameStarted := gameStartedCheck
                if gameStarted = true {
                    break
                }
                ; will try until everything is good
            }

            if gameStarted = false {
                tryReconnect()
                continue
            }
            gamedetected := false
            Loop 240 {
                if not gamedetected {
                    ; trying to detect for infinite sign
                    abc := OCR.FromRect(0, 1000, 500, 80, "en", 1)
                    if RegExMatch(abc.Text, "i)Infinite") {
                        gamedetected := true
                        break
                    }
                    else {
                        Sleep(500)
                    }
                }
            }
            if not gamedetected {
                ; if game wasn't detected
                tryReconnect()
                continue
            }
            ; if game was detected the macro starts a game loop
            gameGoing := true
            if PixelSearch(&x, &y, 81, 25, 81, 25, "0xFFFFFF") {
                MouseMove x, y, 5
                Sleep(300)
                Click
                MouseMove 960, 540, 5
            }

            LookDown()
            Run 'gameloop.ahk', "lib", , &gamelooppid

            global gameloopPIDvar
            gameloopPIDvar := gamelooppid
            ; counter limit aka max game loop time
            ; edit config.ahk2 to change max game loop time
            gameStartedAt := A_Now
            gameEndsAt := DateAdd(gameStartedAt, gameloopTimeLimit, "Minutes")
            statusmessagedate := DateAdd(gameStartedAt, -9, "Seconds")
            while gameGoing = true {
                Loop 2 {
                    if DateDiff(A_Now, statusmessagedate, "Seconds") >= 0 {
                        if DateDiff(A_Now, challengedate, "Minutes") < 0 {
                            challengesin := DateDiff(DateAdd(challengedate, challengesFrequency, "Minutes"), A_Now, "Minutes")
                        }
                        else {
                            challengesin := "Now!"
                        }
                        statusmessagedate := DateAdd(A_Now, statusFreq * 60, "Seconds")
                        Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
                        data2 :=
                            (LTrim Join
                                '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Doing ' mapnames[infinitemap] ' infinite mode \r ### Time left - ' FormatTimer(DateDiff(gameEndsAt, A_Now, "Seconds")) ' \r ### Challenges in - ' challengesin2 '",
                                        "image": {"url": "attachment://ss.png"}, "color": 8487813,
                                "fields": [{"name": "Challenge 1", "value": "' challenge12 '", "inline": true},
                                        {"name": "Challenge 2", "value": "' challenge22 '", "inline": true},
                                        {"name": "Challenge 3", "value": "' challenge32 '", "inline": true}]
                                    }
                                ]
                            }
                                '
                            )
                        webhookPost(data2, { 1: "ss.png" })
                    }
                    ; if counter = 0 it will end the game
                    if DateDiff(gameEndsAt, A_Now, "Seconds") <= 0 {
                        CloseSubScripts()
                        gameloopPIDvar := 0
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                        challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
                        data2 :=
                            (LTrim Join
                                '{
                            "content": "",
                            "embeds": [{
                                    "title": "' date '", "type": "rich", "description": "# Status: About to leave, deleting units \r ### Time spent - ' FormatTimer(gameloopTimeLimit * 60 - DateDiff(gameEndsAt, A_Now, "Seconds")) '",
                                    "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                    "fields": []
                                }
                            ]
                        }
                            '
                            )
                        webhookPost(data2, { 1: "ss.png" })
                        for i in range(5) {
                            Sleep 250
                            Row1L(i, 1)
                            Sleep 250
                            Row1L(i, -1)
                        }
                        while true {
                            if not CheckForDeath() {
                                break
                            }
                            Sleep 2000
                        }
                        gameGoing := false
                        break
                    }
                    if canChallenge or DateDiff(A_YYYY A_MM A_DD A_Hour A_Min, DateAdd(challengedate, challengesFrequency, "Minutes"), "Minutes") >= 0 {
                        challengesin := "Now!"
                    }
                    else {
                        challengesin := DateDiff(DateAdd(challengedate, challengesFrequency, "Minutes"), A_Now, "Minutes")
                    }

                    Sleep(2000)
                }
                if gameGoing = false {
                    break
                }
                ; if death was detected it will end the game and go to lobby, then loop starts again
                deathcheck := CheckForDeath()
                gameGoing := deathcheck
                if not deathcheck {
                    date := FormatTime(A_Now, "[HH:mm:ss]")
                    challengesin2 := challengesin = "Now!" ? challengesin : challengesin " minutes"
                    data2 :=
                        (LTrim Join
                            '{
                            "content": "",
                            "embeds": [{
                                    "title": "' date '", "type": "rich", "description": "# Status: Died \r ### Time spent - ' FormatTimer(gameloopTimeLimit * 60 - DateDiff(gameEndsAt, A_Now, "Seconds")) ' \r ### Challenges in - ' challengesin2 '",
                                    "image": {"url": "attachment://ss.png"}, "color": 12920612,
                                    "fields": []
                                }
                            ]
                        }
                            '
                        )
                    webhookPost(data2, { 1: "ss.png" })
                    break
                }
                reconnect := false
                disconnected := disconnectCheck()
                if disconnected {
                    CloseSubScripts()
                    tryReconnect()
                    reconnect := true
                    gameGoing := false
                    break
                }

            }
        }
        if reconnect {
            lobbydetected := false
            gamedetected := false
            continue
        }


        if not gameGoing {
            lobbydetected := false
            gamedetected := false
            ; after game ended
            disconnected := disconnectCheck()
            if disconnected {
                tryReconnect()
            }
            continue
        }
    }
}

; Called when you stop macro
StopMacro(*)
{
    global myGui
    global canStart
    global macroStarted
    global gdiptoken

    if not macroStarted {
        return
    }
    if canStart {
        return
    }

    myGui.Title := "Severed 1.0 Pre6.4"
    global loopFlag
    global workingscripts
    global gameloopPIDvar
    CloseSubScripts()

    date := FormatTime(A_Now, "[HH:mm:ss]")
    data2 :=
        (LTrim Join
            '{
        "content": "",
        "embeds": [{
                "title": "' date '", "type": "rich", "description": "# Status: Stopped",
                "image": {}, "color": 12920612
            }
        ]
    }
        '
        )
    webhookPost(data2, {})
    loopFlag := false
    Gdip_Shutdown(gdiptoken)
    gdiptoken := 0
    Reload()
}

; Called when you close macro
TerminateMacro(*)
{
    global loopFlag
    global workingscripts
    global gameloopPIDvar
    global gdiptoken
    CloseSubScripts()

    loopFlag := false
    if gdiptoken != 0 {
        Gdip_Shutdown(gdiptoken)
    }
}

; Player align function
AlignPlayer(*)
{
    Send "{s down}"
    Sleep(2700)
    Send "{a down}"
    Send "{s up}"
    Send "{Space down}"
    Sleep(5000)
    Send "{a up}"
    Send "{Space up}"
    Sleep(200)
    Send "{w down}"
    Sleep(4000)
    Send "{w up}"
    Sleep(200)
    Send "{d down}"
    Sleep(500)
    Send "{d up}"
    Send "{a down}"
    Send "{w down}"
    Sleep(750)
    Send "{w up}"
    Send "{a up}"
    Send "{d down}"
    Sleep(1900)
    Send "{d up}"
}

; Summon path
WalkToSummon()
{
    Send "{w down}"
    Sleep 5200
    Send "{d down}"
    Send "{Space down}"
    Sleep 7000
    Send "{d up}"
    Send "{w up}"
    Send "{Space up}"
    Sleep 500
    Send "{a down}"
    Sleep 5000
    Send "{a up}"
    Send "{w down}"
    Sleep(1000)
    Send "{w up}"
    Send "{d down}"
    Send "{s down}"
    Sleep 2200
    Send "{d up}"
    Send "{s up}"
}

; Challenge path
WalkToChallenge(*)
{
    Send "{w down}"
    Sleep 3700
    Send "{w up}"
    Send "{a down}"
    Sleep 8000
    Send "{Space down}"
    Sleep(600)
    Send "{Space up}"

    Sleep 50
    Send "{a up}"
    Send "{w down}"
    Sleep(2000)
    Send "{w up}"
    Send "{a down}"
    Sleep(500)
    Send "{a up}"
    Sleep(250)
    Send "{s down}"
    Sleep(200)
    Send "{s up}"
    Send "{d down}"
    Sleep(750)
    Send "{d up}"
    Sleep(300)
}


; Story path (infinite mode)
WalkToStory(*)
{
    Send "{w down}"
    Sleep 6900
    Send "{a down}"
    Sleep 8000
    Send "{Space down}"
    Sleep(600)
    Send "{Space up}"
    Send "{w up}"
    Sleep 50
    Send "{a up}"
}


; No need to explain
EnterStoryPortal(*)
{
    Send "{w down}"
    Send "{Space down}"
    Sleep 6000
    Send "{w up}"
    Send "{Space up}"
    Sleep(500)
    Send "{s down}"
    Sleep(350)
    Send "{s up}"
    Send "{d down}"
    Sleep 500
    Send "{d up}"
}

; World selection leave
; Usually used when something goes wrong so macro can retry
selectionleave() {
    loop 10 {
        if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1080, "*70 lib\images\leave.png") {
            MouseMove FoundX, FoundY, 3
            Sleep(300)
            Click
            return
        }
        else {
            Sleep 1000
            continue
        }
    }


}

; The same as postselectionleave() but for challenges (they are actually same)
selectionleavechall() {
    clicked := false
    Loop 5 {
        if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1080, "*70 lib\images\leave_challenge.png") {
            MouseMove FoundX, FoundY, 3
            Sleep(300)
            Click
            clicked := true
            break
        }
        Sleep 300
    }
    return clicked
}

; Leaves after world selection (when you can start the game)
postselectionleave() {
    loop 5 {
        if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1080, "*80 lib\images\leave_challenge.png") {
            MouseMove FoundX, FoundY, 3
            Sleep(300)
            Click
            return
        }
        Sleep 300
    }
}

; Starts a challenge
; Tries to enter the portal and start a game
; Returns true on success and false if no success
TryChallengeStart() {
    clicked := false
    Send "{w down}"
    Sleep(1500)
    Send "{w up}"
    Sleep(500)
    Loop 5 {
        for i in ["start_challenge.png", "start_challenge2.png", "start_challenge3.png"] {
            if ImageSearch(&startFoundX, &startFoundY, 0, 0, 1920, 1080, "*90 lib\images\" i) {
                MouseMove startFoundX, startFoundY, 3
                Sleep(300)
                Click
                clicked := true
                break
            }
            else {
                Sleep(600)

            }
        }
    }

    return clicked

}

TryToEStart() {
    gameStarted := false
    loop 5 {
        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\toe_play.png") {
            MouseMove x, y, 5
            Sleep 50
            Click
            Sleep 1000
            ; i took 3 pictures because it was tweaking a bit
            for i in ["start_challenge.png", "start_challenge2.png", "start_challenge3.png"] {
                if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\" i) {
                    MouseMove x, y, 5
                    Sleep 50
                    Click
                    Sleep 500
                    gameStarted := true
                    break
                }
            }
        }
        else {
            Sleep 1000
        }
    }
    return gameStarted
}


; Scrolls through worlds list and finds a needed world
; After it was found, macro clicks on it
; Returns true if was found and false if wasn't
FindMap(maptofind) {
    MouseMove 684, 525, 5
    Sleep(500)
    loop 10 {
        MouseClick "WheelUp", 684, 525, 1
        Sleep 50
    }
    Sleep 300
    loop 10 {
        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*120 " maptofind) {
            MouseMove x, y, 5
            Sleep 50
            Click
            return true
        }
        else {
            MouseClick "WheelDown", 684, 525, 1
            Sleep 300
            continue
        }
    }
    return false
}

TryGameStart() {
    global maps
    global infinitemap
    Send "{w down}"
    Send "{d down}"
    Sleep(1000)
    Send "{w up}"
    Send "{d up}"
    Sleep(300)
    MouseMove 960, 200
    Sleep(200)
    if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1080, "*100 lib\images\selectaworld.png") {
        if not FindMap(maps.%infinitemap%) {
            selectionleave()
            return false
        }

        if not ImageSearch(&friendsFoundX, &friendsFoundY, 0, 0, 1920, 1080, "lib\images\friendscheckbox.png")
        {
            if not ImageSearch(&friendscheckedFoundX, &friendscheckedFoundY, 0, 0, 1920, 1080, "*70 lib\images\friendschecked.png") {
                selectionleave()
                return false
            }
        }

        if friendsFoundX {
            MouseMove friendsFoundX + 10, friendsFoundY + 10, 3
            Sleep(300)
            Click
        }
        Sleep(50)
        if not ImageSearch(&infFoundX, &infFoundY, 0, 0, 1920, 1080, "*100 lib\images\infinitemode.png") {
            selectionleave()
            return false
        }
        MouseMove infFoundX, infFoundY, 3
        Sleep(300)
        Click
        Sleep(50)
        if not ImageSearch(&confirmFoundX, &confirmFoundY, 0, 0, 1920, 1080, "*100 lib\images\confirm.png") {
            selectionleave()
            return false
        }
        MouseMove confirmFoundX, confirmFoundY, 3
        Sleep(300)
        Click
        Sleep(500)
        loop 5 {
            if not ImageSearch(&startFoundX, &startFoundY, 0, 0, 1920, 1080, "*100 lib\images\start.png") {
                postselectionleave()
                return false
            }
            Sleep(200)
        }
        MouseMove startFoundX, startFoundY, 3
        Sleep(300)
        Click
        return true
    }
    else {
        return false
    }

}


; Leader's function
; Used to start a game
; Will wait until all followers join the leader
; Will start as soon as all followers join
; Returns true when game started
TryGameStartLeader() {
    global maps
    global infinitemap
    Send "{s down}"
    Send "{a down}"
    Sleep(500)
    Send "{s up}"
    Send "{a up}"
    Sleep 200
    Send "{w down}"
    Send "{d down}"
    Sleep(1000)
    Send "{w up}"
    Send "{d up}"
    Sleep(300)
    MouseMove 960, 200
    Sleep(200)
    if ImageSearch(&FoundX, &FoundY, 0, 0, 1920, 1080, "*100 lib\images\selectaworld.png") {
        if not FindMap(maps.%infinitemap%) {
            selectionleave()
            return false
        }

        if not ImageSearch(&friendsFoundX, &friendsFoundY, 0, 0, 1920, 1080, "lib\images\friendscheckbox.png")
        {
            if not ImageSearch(&friendscheckedFoundX, &friendscheckedFoundY, 0, 0, 1920, 1080, "*70 lib\images\friendschecked.png") {
                selectionleave()
                return false
            }
        }

        if friendsFoundX {
            MouseMove friendsFoundX + 10, friendsFoundY + 10, 5
            Sleep(300)
            Click
        }
        Sleep(50)
        if not ImageSearch(&infFoundX, &infFoundY, 0, 0, 1920, 1080, "*100 lib\images\infinitemode.png") {
            selectionleave()
            return false
        }
        MouseMove infFoundX, infFoundY, 5
        Sleep(300)
        Click
        Sleep(50)
        if not ImageSearch(&confirmFoundX, &confirmFoundY, 0, 0, 1920, 1080, "*100 lib\images\confirm.png") {
            selectionleave()
            return false
        }
        MouseMove confirmFoundX, confirmFoundY, 5
        Sleep(300)
        Click
        Sleep(500)
        loop 5 {
            if not ImageSearch(&startFoundX, &startFoundY, 0, 0, 1920, 1080, "*100 lib\images\start.png") {
                postselectionleave()
                return false
            }
            Sleep(200)
        }
        loop 10 {
            if checkFollowers() {
                MouseMove startFoundX, startFoundY, 5
                Sleep(300)
                Click
                return true
            }
            else {
                Sleep 5000
            }
        }
        postselectionleave()
        return false

    }
    else {
        Sleep 7500
        return false
    }

}

; Follower's function
; Used to join leader's portal
; Leaves the portal if leader isn't there
; Function returns true if infinite sign was detected (game started)
TryLeaderJoin() {
    Send "{w down}"
    Send "{d down}"
    Sleep(1000)
    Send "{w up}"
    Send "{d up}"
    Sleep 300

    return checkLeader()
}

CheckForDeath(*) {
    ; Define the image path (adjust the path as necessary)
    ; Coordinates of the area to search (left, top, right, bottom)
    searchLeft := 0
    searchTop := 0
    searchRight := 1920
    searchBottom := 1080

    tolerance := 10 ; Adjusted tolerance

    ; Search for the image on the screen
    ; Debugging output

    ; Check if the image was found
    if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\backtolobby.png") {
        global workingscripts
        global gameloopPIDvar
        CloseSubScripts()

        Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
        MouseMove(x, y, 5)
        Sleep(200)
        Click()
        Sleep(150)
        Click()
        MouseMove(960, 540, 5)
        Sleep 500
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\backtolobby.png") {
            global workingscripts
            global gameloopPIDvar
            CloseSubScripts()

            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
            MouseMove(x, y, 5)
            Sleep(200)
            Click()
            Sleep(150)
            Click()
            MouseMove(960, 540, 5)
            Sleep 500
        }
        return false
    }
    else
    {
        return true
    }
}

; Checks if you won or were defeated in challenges
; Returns:
;   - 0: You won
;   - 1: You were defeated
;   - 2: Nothing was detected
CheckForWin(*) {
    ; Define the image path (adjust the path as necessary)

    ; Coordinates of the area to search (left, top, right, bottom)
    searchLeft := 0
    searchTop := 0
    searchRight := 1920
    searchBottom := 1080

    ; Search for the image on the screen
    ; Debugging output

    ; Check if the image was found
    win := -1
    Loop 2 { ; looping 2 times to make sure
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\victory.png") {
            win := 0
        }
        else if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\defeat.png") {
            win := 1
        }
    }

    if win = 0 or win = 1 {
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\backtolobby.png") {
            global workingscripts
            global gameloopPIDvar
            CloseSubScripts()

            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
            MouseMove(x, y, 5)
            Sleep(200)
            Click()
            Sleep(150)
            Click()
            MouseMove(960, 540, 5)
            Sleep 500
            if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\backtolobby.png") {
                global workingscripts
                global gameloopPIDvar
                CloseSubScripts()

                Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                MouseMove(x, y, 5)
                Sleep(200)
                Click()
                Sleep(150)
                Click()
                MouseMove(960, 540, 5)
                Sleep 500
            }
            return win
        }
    }

    return 2
}

; Checks if you won or were defeated in Tower of Eternity
; also checks for captcha and does it if needed
; Returns:
;   - 0: You won, no captcha | You won, successful captcha
;   - 1: You were defeated, no captcha | You were defeated, successful captcha
;   - 3: You won, failed captcha
;   - 4: You were defeated, failed captcha
;   - 2: Nothing was detected
CheckForToEWin(*) {
    ; Define the image path (adjust the path as necessary)

    ; Coordinates of the area to search (left, top, right, bottom)
    searchLeft := 0
    searchTop := 0
    searchRight := 1920
    searchBottom := 1080

    ; Search for the image on the screen
    ; Debugging output

    ; Check if the image was found
    win := -1
    Loop 2 { ; looping 2 times to make sure
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\victory.png") {

            win := 0
        }
        else if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\defeat.png") {
            win := 1
        }
    }

    if win = 0 {
        loop 3 {
            if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\toe_play_next.png") {
                global workingscripts
                global gameloopPIDvar
                CloseSubScripts()

                Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                MouseMove(x, y, 5)
                Sleep(200)
                Click()
                Sleep 1000
                success := checkCaptcha(true)
                Sleep 1000
                if success = 0 {
                    return 3
                }
                if success = 1 {
                    MouseMove(x, y, 5)
                    Sleep 50
                    Click()
                }
                return win
            }
        }
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\toe_backtolobby.png") {
            global workingscripts
            global gameloopPIDvar
            CloseSubScripts()

            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
            MouseMove(x, y, 5)
            Sleep(200)
            Click()
            Sleep 1000
            success := checkCaptcha(true)
            Sleep 1000
            if success = 0 {
                return 4
            }
            if success = 1 {
                MouseMove(x, y, 5)
                Sleep 50
                Click()
                MouseMove(960, 540, 5)
                Sleep 500
                if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\toe_backtolobby.png") {
                    global workingscripts
                    global gameloopPIDvar
                    CloseSubScripts()

                    Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                    MouseMove(x, y, 5)
                    Sleep(200)
                    Click()
                    Sleep(150)
                    Click()
                    MouseMove(960, 540, 5)
                    Sleep 500
                }
            }
            return win
        }
    }

    if win = 1 {
        if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\toe_backtolobby.png") {
            global workingscripts
            global gameloopPIDvar
            CloseSubScripts()

            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
            MouseMove(x, y, 5)
            Sleep(200)
            Click()
            Sleep 1000
            success := checkCaptcha(true)
            Sleep 1000
            if success = 0 {
                return 4
            }
            if success = 1 {
                MouseMove(x, y, 5)
                Sleep 50
                Click()
                MouseMove(960, 540, 5)
                Sleep 500
                if ImageSearch(&x, &y, searchLeft, searchTop, searchRight, searchBottom, "*110 lib\images\toe_backtolobby.png") {
                    global workingscripts
                    global gameloopPIDvar
                    CloseSubScripts()

                    Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                    MouseMove(x, y, 5)
                    Sleep(200)
                    Click()
                    Sleep(150)
                    Click()
                    MouseMove(960, 540, 5)
                    Sleep 500
                }
                return win
            }
        }
        return 2
    }
}


; Reconnect function
; Uses private server code link to reconnect (took this from natro macro)
; It uses deeplink method so no browser required
tryReconnect() {

    global reconnects
    global gamereconnectlink
    global gamereconnectlinkps
    global privateservercode
    sleeptime := 15
    ;SetTimer closeChat, 0
    ;SetTimer closeUpdate, 0

    if roblox := WinExist("ahk_exe" "RobloxPlayerBeta.exe") {
        ProcessClose WinGetPID("ahk_id" roblox)
        date := FormatTime(A_Now, "[HH:mm:ss]")
        data2 :=
            (LTrim Join
                '{
            "content": "",
            "embeds": [{
                    "title": "' date '", "type": "rich", "description": "# Status: Reconnecting in ' sleeptime ' seconds",
                    "image": {}, "color": 8487813,
                    "fields": []
                }
            ]
        }
            '
            )
        webhookPost(data2, {})
        Sleep(sleeptime * 1000)
    }
    else {
        date := FormatTime(A_Now, "[HH:mm:ss]")
        data2 :=
            (LTrim Join
                '{
            "content": "",
            "embeds": [{
                    "title": "' date '", "type": "rich", "description": "# Status: Reconnecting ",
                    "image": {}, "color": 8487813,
                    "fields": []
                }
            ]
        }
            '
            )
        webhookPost(data2, {})
    }
    if privateservercode != "0" {
        try Run gamereconnectlinkps privateservercode
    }
    else {
        try Run gamereconnectlink
    }


    while not WinExist("ahk_exe" "RobloxPlayerBeta.exe") {
        Sleep(1000)
    }
    Sleep(4000)
    while not WinActive("ahk_exe" "RobloxPlayerBeta.exe") {
        WinActivate "ahk_exe" "RobloxPlayerBeta.exe"
    }

    Sleep(1000)
    WinGetClientPos &x, &y, &w, &h, "ahk_exe" "RobloxPlayerBeta.exe"
    if h != 1080 {
        Send "{F11}"
    }
    Sleep(4000)
    reconnects += 1
}


; Checks:
;   - If roblox task exists
;   - If roblox crash window exists
;   - If disconnect or join error are on the screen
; If any of those were detected returns true, else false
disconnectCheck() {
    global disconnects
    global webhookPing
    date := FormatTime(A_Now, "[HH:mm:ss]")
    data :=
        (LTrim Join
            '{
            "content": "' webhookPing '",
            "embeds": [{
                    "title": "' date '", "type": "rich", "description": "# Status: Disconnected \r ### - Trying to reconnect",
                    "image": {"url": "attachment://disconnect.png"}, "color": 9838624,
                    "fields": []
                }
            ]
        }
'
        )
    if WinExist("Roblox Crash") {
        disconnects += 1
        Gdip_SaveBitmapToFile(b := Gdip_BitmapFromScreen("0|0|1920|1080"), "disconnect.png")
        Gdip_DisposeImage(b)
        webhookPost(data, { disconnect: "disconnect.png" })
        return true
    }
    if not WinExist("ahk_exe" "RobloxPlayerBeta.exe") {
        disconnects += 1
        Gdip_SaveBitmapToFile(b := Gdip_BitmapFromScreen("0|0|1920|1080"), "disconnect.png")
        Gdip_DisposeImage(b)
        webhookPost(data, { disconnect: "disconnect.png" })
        ; 693, 877, 500, 100
        return true
    }
    detectcounter := 0
    for i in ["disconnect1.png", "disconnect2.png", "disconnect3.png"] {
        Loop 2 {
            if ImageSearch(&x, &y, 300, 200, 1620, 880, "lib\images\" i) {
                detectcounter += 1

            }
        }

    }
    if detectcounter = 0 {
        for i in ["joinerror1.png", "joinerror2.png", "joinerror3.png"] {
            Loop 2 {
                if ImageSearch(&x, &y, 300, 200, 1620, 880, "lib\images\" i) {
                    detectcounter += 1
                }
            }
        }
    }
    if detectcounter >= 3 {
        disconnects += 1
        Gdip_SaveBitmapToFile(b := Gdip_BitmapFromScreen("0|0|1920|1080"), "disconnect.png")
        Gdip_DisposeImage(b)
        webhookPost(data, { disconnect: "disconnect.png" })
    }
    return detectcounter >= 3
}


; Took this from Dolphsol macro
; All credits to BuilderDolphin
Class CreateFormData {

    __New(&retData, &retHeader, objParam) {

        Local CRLF := "`r`n", i, k, v, str, pvData
        ; Create a random Boundary
        Local Boundary := this.RandomBoundary()
        Local BoundaryLine := "------------------------------" . Boundary

        this.Len := 0 ; GMEM_ZEROINIT|GMEM_FIXED = 0x40
        this.Ptr := DllCall("GlobalAlloc", "UInt", 0x40, "UInt", 1, "Ptr") ; allocate global memory

        ; Loop input paramters
        For k, v in objParam.OwnProps()
        {
            If IsObject(v) {
                For i, FileName in v
                {
                    str := BoundaryLine . CRLF
                        . "Content-Disposition: form-data; name=" "" . k . "" "; filename=" "" . FileName . "" "" . CRLF
                        . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
                    this.StrPutUTF8(str)
                    this.LoadFromFile(Filename)
                    this.StrPutUTF8(CRLF)
                }
            } Else {
                str := BoundaryLine . CRLF
                    . "Content-Disposition: form-data; name=" "" . k "" "" . CRLF . CRLF
                    . v . CRLF
                this.StrPutUTF8(str)
            }
        }

        this.StrPutUTF8(BoundaryLine . "--" . CRLF)

        ; Create a bytearray and copy data in to it.
        retData := ComObjArray(0x11, this.Len) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
        pvData := NumGet(ComObjValue(retData) + 8 + A_PtrSize, "Ptr")
        DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", this.Ptr, "Ptr", this.Len)

        this.Ptr := DllCall("GlobalFree", "Ptr", this.Ptr, "Ptr") ; free global memory

        retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
    }

    StrPutUTF8(str) {
        Local ReqSz := StrPut(str, "utf-8") - 1
        this.Len += ReqSz ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42
        this.Ptr := DllCall("GlobalReAlloc", "Ptr", this.Ptr, "UInt", this.len + 1, "UInt", 0x42)
        StrPut(str, this.Ptr + this.len - ReqSz, ReqSz, "utf-8")
    }

    LoadFromFile(Filename) {
        Local objFile := FileOpen(FileName, "r")
        this.Len += objFile.Length ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42
        this.Ptr := DllCall("GlobalReAlloc", "Ptr", this.Ptr, "UInt", this.len, "UInt", 0x42)
        objFile.RawRead(this.Ptr + this.Len - objFile.length, objFile.length)
        objFile.Close()
    }

    RandomBoundary() {
        str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
        Sort str, "D| Random"
        str := StrReplace(str, "|")
        Return SubStr(str, 1, 12)
    }

    MimeType(FileName) {
        n := FileOpen(FileName, "r").ReadUInt()
        Return (n = 0x474E5089) ? "image/png"
            : (n = 0x38464947) ? "image/gif"
                : (n & 0xFFFF = 0x4D42) ? "image/bmp"
                    : (n & 0xFFFF = 0xD8FF) ? "image/jpeg"
                        : (n & 0xFFFF = 0x4949) ? "image/tiff"
                            : (n & 0xFFFF = 0x4D4D) ? "image/tiff"
                                : "application/octet-stream"
    }

}


; Took this from Dolphsol macro and Natro macro
; All credits to them
webhookPost(dataStr, files) {
    global webhookURL
    webhookMessages := IniRead("config.ini", "config", "webhookMessages")
    url := webhookURL
    if not webhookMessages {
        return
    }

    objParam := { payload_json: dataStr }

    for i, v in (files ? files.OwnProps() : []) {
        objParam.%i% := [v]
    }
    CreateFormData(&a, &b, objParam)
    try {
        WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
        WebRequest.Option[9] := 2720
        WebRequest.Open("POST", url, 1)
        WebRequest.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
        WebRequest.SetRequestHeader("Content-Type", b)
        WebRequest.Send(a)
        WebRequest.WaitForResponse(10)
    }
}

; took from dolphsol macro that took from natro macro xd
validateWebhookLink(link) {
    return RegExMatch(link, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)") ; filter by natro
}

; Writes values from old config to a new config (aka import settings).
; Needs a configuration file to take values from it.
; Only adds if old config has matching keys.
addOldIniValues(*) {
    paramsnew := {}
    paramsold := {}
    configold := FileSelect(, , "Select your old config", "Configuration (*.ini)")

    config1 := IniRead(configold, "config")
    keyvalue1 := StrSplit(config1, "`n")
    for i in keyvalue1 {
        RegExMatch(i, "(.*)=(.*)", &abc)
        if InStr(abc[1], "privateServerLink=") {
            RegExMatch(i, "(privateServerLink)=(.*)", &abc2)
            paramsnew.%abc2[1]% := abc2[2]
            continue
        }

        paramsnew.%abc[1]% := abc[2]
    }

    try {
        config2 := IniRead("config_default.ini", "config")
    }
    catch Error as err {
        MsgBox "config_default.ini wasn't found."
        ExitApp
    }

    keyvalue2 := StrSplit(config2, "`n")
    for i in keyvalue2 {
        RegExMatch(i, "(.*)=(.*)", &abc)
        paramsold.%abc[1]% := abc[2]
    }

    for i, k in paramsold.OwnProps() {
        if paramsnew.HasOwnProp(i) {

            IniWrite(paramsnew.%i%, "config.ini", "config", i)
        }
        else {
            IniWrite(k, "config.ini", "config", i)
        }
    }
    Reload
}

; Does the whole auto summon thing
; At first checks for at least 1 unit from user's units list
; If at least 1 unit was found in a banner it will roll if you have enough gems and auto summon is enabled
; Hourly banners as well
summonRun() {
    global units
    global summonmax
    global autosummon
    global hourlybanners
    global webhookPing
    counter := 1
    counter2 := 1
    Send "{e 1}"
    Sleep(1000)
    findbanner := OCR.FromRect(600, 430, 800, 220, "en", 3)
    ssmade := false
    foundunit := false
    foundunit2 := false
    unitssummoned := false
    bannerssent := false
    for t in [1, 2] {
        if t = 1 and hourlybanners = 1 {
            banner1 := false
            banner2 := false
            /*
            for i in findbanner.Words {*/
            Sleep(1000)
            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "banner1.png")
            banner1 := true
            Send "{e 1}"
            Sleep(500)
            counter2 += 1
            ;continue
            /*    else if RegExMatch(i.Text, "i)Limi") and counter2 = 2 {
                    findbanner.Click(i)
                    Sleep(1000)
            
                    findbanner.Click(i)
                    Sleep(1000)
                    Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "banner2.png")
                    banner2 := true
                    Send "{e 1}"
                    Sleep 500
                    break
                }
            }
            */
            date := FormatTime(A_Now, "[HH:mm:ss]")
            data :=
                (LTrim Join
                    '{
                        "content": "' webhookPing '",
                        "embeds": [{
                                "title": "' date '", "type": "rich", "description": "# Hourly banners! \r ### - Standard",
                                "image": {"url": "attachment://banner1.png"}, "color": 11390957,
                                "fields": []
                            }
                        ]
                    }
                '
                )
            if banner1 {
                if banner2 {
                    data := data
                    (LTrim Join
                        '{
                                "content": "' webhookPing '",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Hourly banners! \r ### - Standard",
                                        "image": {"url": "attachment://banner1.png"}, "color": 11390957,
                                        "fields": []
                                    },{
                                "title": "", "type": "rich", "description": "### - Limited",
                                "image": {"url": "attachment://banner2.png"}, "color": 8944880,
                                "fields": []
                        }
                    ]
                }
        '
                    )
                    webhookPost(data, { 1: "banner1.png", 2: "banner2.png" })
                }
                else {
                    webhookPost(data, { 1: "banner1.png" })
                }

            }
            continue
        }
        if t = 2 and autosummon = 1 {
            for y in [1] {
                /*for i in findbanner.Words {
                    if RegExMatch(i.Text, "i)Stan") and counter = 1 {
                        findbanner.Click(i)
                        Sleep(1000)
                        foundunit := true
                    }
                    else if RegExMatch(i.Text, "i)Lim") and counter = 2 {
                        findbanner.Click(i)
                        Sleep(1000)
                }*/
                foundunit := true
                if not foundunit {
                    continue
                }
                found := false
                loop 3 {
                    findunit := OCR.FromRect(750, 450, 800, 190, "en", 2)
                    ToolTip findunit.Text, 1600, 300
                    for i, k in findunit.Lines {
                        for b, n in units {
                            checkresult := checkSimilarity(n, RegExReplace(StrReplace(StrLower(k.Text), " ", ""), "[^A-Za-z0-9]"))
                            if checkresult.similar {
                                found := true
                                unit := n
                                date := FormatTime(A_Now, "[HH:mm:ss]")
                                data :=
                                    (LTrim Join
                                        '{
                                        "content": "' webhookPing '",
                                        "embeds": [{
                                                "title": "' date '", "type": "rich", "description": "# Status: Detected keyword unit - ' unit '",
                                                "image": {}, "color": 15656042,
                                                "fields": []
                                            }
                                        ]
                                    }
                            '
                                    )
                                webhookPost(data, {})
                                break
                            }
                            unit := n
                        }
                        if not found {
                            continue
                        }
                        if found {
                            break
                        }
                    }
                    if not found {
                        continue
                    }
                    if found {
                        break
                    }
                }
                if not found {
                    Send "{e 1}"
                    counter += 1
                    foundunit := false
                    Sleep(1500)
                    break
                }
                if found {
                    gems := OCR.FromRect(1355, 717, 250, 40)

                    try {
                        gems := Number(StrReplace(gems.Text, ",", ""))
                    }
                    catch Error as err {
                        return true
                    }

                    a := summonUnits(units, summonmax, gems)
                    if a != false {
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        data :=
                            (LTrim Join
                                '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Status: Summoned ' a.spentrolls ' units \r### - Gems spent - ' a.spentgems '\r### - Got units - ' a.gotunits '",
                                        "image": {}, "color": 9172555,
                                        "fields": []
                                    }
                                ]
                            }
                    '
                            )
                        webhookPost(data, {})
                    }
                }
                return true
            }
        }
        date := FormatTime(A_Now, "[HH:mm:ss]")
        data :=
            (LTrim Join
                '{
                        "content": "",
                        "embeds": [{
                                "title": "' date '", "type": "rich", "description": "# Status: No keyword units in these banners :( \rCurrent keywords: ' unitsstring '",
                                "image": {}, "color": 14157325,
                                "fields": []
                            }
                        ]
                    }
            '
            )
        webhookPost(data, {})
        return true
    }
}


; Summon function
; Takes next parameters:
;   - units - keyword units list
;   - summons - max summons script needs to do
;   - gems - gems that player has
; Returns an object:
;   - spentgems - Spent gems
;   - spentrolls - Rolls were done
;   - gotunit - How many keyword units you got
; On fail returns false
summonUnits(units, summons, gems) {
    global gemsmin
    global hasvip
    global maxunits
    price := hasvip ? 40 : 50
    gotunit := 0
    if gems < gemsmin {
        date := FormatTime(A_Now, "[HH:mm:ss]")
        data :=
            (LTrim Join
                '{
                "content": "",
                "embeds": [{
                        "title": "' date '", "type": "rich", "description": "# Status: Summon failed\r### - Not enough gems (' gems ')",
                        "image": {}, "color": 14157325,
                        "fields": []
                    }
                ]
            }
    '
            )
        webhookPost(data, {})
        return false
    }

    summons1 := summons
    gems1 := gems

    while (summons > 0 and gems > price) and gotunit < maxunits {
        Sleep(3000)
        if ((gems >= price * 10) and (summons >= 10) and (gems - price * 10 > gemsmin)) {
            date := FormatTime(A_Now, "[HH:mm:ss]")
            data :=
                (LTrim Join
                    '{
                    "content": "",
                    "embeds": [{
                            "title": "' date '", "type": "rich", "description": "# Status: Summoning 10\r ### - Rolls left - ' summons ' \r ### - Gems left - ' gems '",
                            "image": {}, "color": 14217431,
                            "fields": []
                        }
                    ]
                }
        '
                )
            webhookPost(data, {})
            summontext := OCR.FromRect(1312, 763, 140, 190, "en", 4)
            for i, k in summontext.Lines {
                if i = 2 {
                    summontext.Click(k)
                    Sleep(4500)
                    loop 10 {
                        loop 5 {
                            unitgot := OCR.FromRect(564, 770, 900, 100, "en", 3)
                            unitgot := RegExReplace(StrReplace(StrLower(unitgot.Text), " ", ""), "[^A-Za-z0-9]")
                            result := similarIn(unitgot, units)
                            got := false
                            if result.similar {
                                date := FormatTime(A_Now, "[HH:mm:ss]")
                                ftext := "OCR result - " Round(result.result, 1) "/30"
                                data :=
                                    (LTrim Join
                                        '{
                                        "content": "' webhookPing '",
                                        "embeds": [{
                                                "title": "' date '", "type": "rich", "description": "# You got a ' result.name '!\r",
                                                "image": {"url": "attachment://ss.png"}, "color": 16774731,
                                                "fields": [], "footer": {"text": "' ftext '"}
                                            }
                                        ]
                                    }
                            '
                                    )
                                Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                                webhookPost(data, { 1: "ss.png" })
                                Click
                                Sleep(1000)
                                gotunit += 1
                                got := true
                                break
                            }
                        }
                        if not got {
                            Click
                            Sleep(400)
                        }
                    }
                    summons -= 10
                    gems -= price * 10
                }
                if i = 2 {
                    break
                }
            }

        }
        else if ((gems >= price) and (summons >= 1) and (gems - price * 1 > gemsmin)) {
            date := FormatTime(A_Now, "[HH:mm:ss]")
            data :=
                (LTrim Join
                    '{
                    "content": "",
                    "embeds": [{
                            "title": "' date '", "type": "rich", "description": "# Status: Summoning 1\r ### - Rolls left - ' summons ' \r ### - Gems left - ' gems '",
                            "image": {}, "color": 14217431,
                            "fields": []
                        }
                    ]
                }
        '
                )
            webhookPost(data, {})
            summontext := OCR.FromRect(1312, 763, 140, 190, "en", 4)
            for i, k in summontext.Lines {
                if i = 1 {
                    summontext.Click(k)
                    Sleep(4500)
                    got := false
                    loop 5 {
                        unitgot := OCR.FromRect(564, 790, 900, 100, "en", 3)
                        unitgot := StrReplace(StrReplace(StrReplace(StrReplace(StrLower(unitgot.Lines[1].Text), " ", ""), ",", ""), "-", ""), "'", "")
                        result := similarIn(unitgot, units)
                        if result.similar {
                            date := FormatTime(A_Now, "[HH:mm:ss]")
                            ftext := "OCR result - " Round(result.result, 1) "/30"
                            data :=
                                (LTrim Join
                                    '{
                                    "content": "' webhookPing '",
                                    "embeds": [{
                                            "title": "' date '", "type": "rich", "description": "# You got a ' result.name '!\r",
                                            "image": {"url": "attachment://ss.png"}, "color": 16774731,
                                            "fields": [], "footer": {"text": "' ftext '"}
                                        }
                                    ]
                                }
                        '
                                )
                            Gdip_SaveBitmapToFile(Gdip_BitmapFromScreen("0|0|1920|1080"), "ss.png")
                            webhookPost(data, { 1: "ss.png" })
                            Click
                            Sleep(1000)
                            gotunit += 1
                            got := true
                            break
                        }
                    }
                    if not got {
                        Click
                        Sleep(400)
                    }
                    summons -= 1
                    gems -= price
                }
                if i = 1 {
                    break
                }
            }
        }
    }
    return { spentgems: gems1 - gems, spentrolls: summons1 - summons, gotunits: gotunit }
}

; -1 = false captcha
; 0 = captcha failed
; 1 = successful captcha
checkCaptcha(captchaDo := false) {
    detected := -1
    loop 3 {
        if OCR.FromRect(640, 413, 660, 212, "en", 4).Text = "Loading..." {
            detected := true
            detected2 := false
            loop 3 {
                if PixelGetColor(956, 624) = "0xFFFFFF" and PixelGetColor(950, 415) = "0xFFFFFF" {
                    detected2 := true
                    if captchaDo {
                        success := doCaptcha()
                        if success = -1 {
                            return -1
                        }
                        else if success = 0
                            return 0
                    }
                }
                else {
                    Sleep(2000)
                }
            }
            if detected2 = false {
                detected := false
            }
        }
        else if PixelGetColor(956, 624) = "0xFFFFFF" and PixelGetColor(950, 415) = "0xFFFFFF" {
            detected := true
            if captchaDo {
                success := doCaptcha()
                if success = -1 {
                    return -1
                }
                else if success = 0
                    return 0
            }
        }
        else {
            Sleep(2000)
        }
    }
    return detected
}

; Does captcha
; Returns:
;   - 1: successful captcha
;   - 0: unsuccessful captcha
;   - -1: cannot find any captcha text (false detection)
doCaptcha() {
    Sleep(5000)
    captchabox := OCR.FromRect(640, 413, 700, 230, "en", 1)
    if captchabox.Text = "" {
        return -1
    }
    captchasuccess := false
    captchalist := StrSplit(StrReplace(captchabox.Text, " ", ""))
    loop 3 {
        MouseMove 807, 739, 5
        Sleep 50
        Click
        for i in captchalist {
            Send "{" i " 1}"
            Sleep(300)
        }
        MouseMove 807, 665, 5
        Sleep 100
        Click
        loop 3 {
            if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\submit.png") {
                MouseMove x, y, 5
                Sleep 50
                Click
                MouseMove 807, 665, 5
                Sleep 2000
                if not checkCaptcha() {
                    return true
                }
                else {
                    Sleep(2000)
                    break
                }
            }
        }
    }
    return false
}

; Leader's function
; Checks if all followers are in the place
; Returns true if all followers are in the place, else returns false
checkFollowers() {
    global followers
    countercap := followers.Length
    counter := 0
    a := OCR.FromRect(1391, 555, 522, 464, "en", 1)
    for i in followers {
        for k in a.Words {
            b := checkSimilarity(StrLower(k.Text), i)
            if b.similar {
                counter += 1
                break
            }
        }
    }
    if counter = countercap {
        return true
    }
    else {
        return false
    }
}

; Follower's function
; Checks if:
;   - There's a leader in the portal
;   - Game started
; Returns true if game started
checkLeader() {
    global leader
    foundleader := false
    noleadercounter := 0
    failcounter := 0
    loop 3 {
        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\selectaworld.png") {
            selectionleave()
            Sleep 15000
            return false
        }
        else {
            Sleep 200
        }
    }
    loop 30 {
        if failcounter > 15 {
            return 2
        }
        abc := OCR.FromRect(0, 1000, 500, 80, "en", 1)
        if RegExMatch(abc.Text, "i)Infinite") {
            if not foundleader {
                date := FormatTime(A_Now, "[HH:mm:ss]")
                data :=
                    (LTrim Join
                        '{
                        "content": "",
                        "embeds": [{
                                "title": "' date '", "type": "rich", "description": "# Multi macro: Leader was found! Waiting for the leader to start a game",
                                "image": {}, "color": 8487813
                            }
                        ]
                    }
                        '
                    )
                webhookPost(data, {})
            }
            return true
        }

        if not ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\shop.png") {
            if not ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\leave_challenge.png") {
                Sleep 5000
                failcounter += 1
                continue
            }
        }

        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\shop.png") {
            if not ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\leave_challenge.png") {
                Sleep 5000
                return false
            }
        }

        if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*100 lib\images\leave_challenge.png") {
            if not foundleader {
                if noleadercounter > 3 {
                    postselectionleave()
                    Sleep 15000
                    return false
                }
                a := OCR.FromRect(1391, 555, 522, 464, "en", 1)
                for i in a.Words {
                    b := checkSimilarity(StrLower(i.Text), leader)
                    if b.similar {
                        date := FormatTime(A_Now, "[HH:mm:ss]")
                        data :=
                            (LTrim Join
                                '{
                                "content": "",
                                "embeds": [{
                                        "title": "' date '", "type": "rich", "description": "# Multi macro: Leader was found! Waiting for the leader to start a game",
                                        "image": {}, "color": 8487813
                                    }
                                ]
                            }
                                '
                            )
                        webhookPost(data, {})
                        foundleader := true
                        break
                    }
                }
                if foundleader = false {
                    noleadercounter += 1
                }
            }
        }
        Sleep 5000
    }
    postselectionleave()
    return false
}

LookDown()
{
    Send "{i down}"
    Sleep 2500
    Send "{i up}"
    Sleep 100
    MouseMove(0, 200, 50, "R")
    Sleep 350
    Send "{o down}"
    Sleep 2500
    Send "{o up}"
    Sleep 150
}

AlignPlayerToE(*)
{
    Send "{s down}"
    for i in range(5) {
        Send "{Space down}"
        Sleep 50
        Send "{Space up}"
        Sleep 250
        Send "{Space down}"
        Sleep 50
        Send "{Space up}"
        Sleep 1100
    }
    Sleep 1000
    Send "{s up}"
    Sleep 50
    Send "{w down}"
    Sleep 2200
    Send "{w up}"
}

DeleteUnit() {
    Sleep 50
    Click
    Sleep 300
    if ImageSearch(&x, &y, 0, 0, 1920, 1080, "*90 lib\images\delete.png") {
        MouseMove x, y
        Sleep 100
        Click
        Sleep 300
        if ImageSearch(&x1, &y1, 0, 0, 1920, 1080, "*90 lib\images\sell.png") {
            MouseMove x1, y1
            Sleep 100
            Click
            Sleep 50
            MouseMove 960, 540
            Sleep 50
        }
    }
}

Row1L(rowcount, minus) {
    Loop (3)
    {
        Sleep 200
        MouseMove(960 - (90 * A_Index * minus), 270 + 90 * rowcount, 5)
        DeleteUnit()
    }
}

CloseSubScripts() {
    for i in WinGetList("ahk_exe" "AutoHotkey64.exe") {
        try {
            SendMessage "11111", , , , "ahk_id " i
        }
    }
    for i in WinGetList("ahk_exe" "AutoHotkey64_UIA.exe") {
        try {
            SendMessage "11111", , , , "ahk_id " i
        }
    }
}