Scriptname zadRMGagSliders extends RaceMenuBase

zadlibs Property libs auto

string Property CATEGORY_KEY = "DeviousDevices" AutoReadOnly

Event OnCategoryRequest()
    AddCategory(CATEGORY_KEY, "DD - Gag",90)
EndEvent

Actor       _TargetActor
String[]    _GagExp
Int         _GagExpSet = 0
Bool        _GagExpShow = False
Bool        _GagSave = False
Bool        _GagLoad = False

Event OnSliderRequest(Actor target, ActorBase targetBase, Race actorRace, bool isFemale)
    _TargetActor = target
    
    _ValidateGagExp()
    
    AddSliderEx("Show Gag Expression", CATEGORY_KEY, "Gag_ExpressionShow", 0.0, 1.0, 1.0, _GagExpShow as Int)
    AddSliderEx("Save to preset", CATEGORY_KEY, "Gag_ExpressionSave", 0.0, 1.0, 1.0, _GagSave as Int)
    AddSliderEx("Load from preset", CATEGORY_KEY, "Gag_ExpressionLoad", 0.0, 1.0, 1.0, _GagLoad as Int)
    AddSliderEx("Gag Expression", CATEGORY_KEY, "Gag_ExpressionSet", 0.0, 4.0, 1.0, _GagExpSet)
    _CreateGagExpSliders()
EndEvent

Event OnSliderChanged(string callback, float value)
    _CheckGagMorph(callback,value)
EndEvent

bool _GagSetChangeMutex = False
Bool Function _CheckGagMorph(String asMorph, Float afValue)
    if  asMorph == "Gag_ExpressionShow"
        _GagExpShow = Round(afValue)
        if _GagExpShow
            RegisterForSingleUpdate(0.5)
            _UpdateGagExpression()
        else
            _RemoveGagExpression()
        endif
    elseif asMorph == "Gag_ExpressionSave"
        ;save morphs to preset
        _GagSave = Round(afValue)
        if _GagSave
            _SaveGagMorphs()
        endif
    elseif asMorph == "Gag_ExpressionLoad"
        ;load morphs from preset
         _GagLoad = Round(afValue)
        if _GagLoad
            _LoadGagMorphs()
        endif
    elseif asMorph == "Gag_ExpressionSet"
        if _GagSetChangeMutex
            SetSliderParameters("Gag_ExpressionSet",0.0, 4.0, 1.0, _GagExpSet)
            ConsoleUtil.PrintMessage("Cant change set as previous set is still not loaded!")
        else
            _GagSetChangeMutex = True
            _GagExpSet = Round(afValue)
            _UpdateGagExpSliders()
            _GagSetChangeMutex = False
        endif
    Endif
    _CheckGagExpSliders(asMorph,afValue)
    return false
EndFunction

Function _ApplyMorph(String asMorph, Float afValue)
    NiOverride.SetBodyMorph(_TargetActor, asMorph, "DeviousDevices", afValue)
    NiOverride.UpdateModelWeight(_TargetActor)
EndFunction

Function _UpdateGagExpression(Bool loc_force = false)
    if _GagExpShow || loc_force
        if _TargetActor.WornHasKeyword(libs.zad_DeviousGag)
            libs.ExpLibs.ApplyGagEffect(_TargetActor)
        endif
    endif
EndFunction

Function _RemoveGagExpression()
    libs.ExpLibs.RemoveGagEffect(_TargetActor)
EndFunction

Function _ValidateGagExp()
    Faction[] loc_set = _GetGagExpSet()
    _GagExp = Utility.CreateStringArray(loc_set.length)
    int loc_i = 0
    while loc_i < _GagExp.length
        _GagExp[loc_i] = ("GagExpChange"+loc_i)
        loc_i += 1
    endwhile
EndFunction

Function _CreateGagExpSliders()
    Faction[] loc_set = _GetGagExpSet()
    int loc_i = 0
    while loc_i < loc_set.length
        AddSliderEx("Gag Exp " + loc_i, CATEGORY_KEY, _GagExp[loc_i], -1, 100, 1, _TargetActor.GetFactionRank(loc_set[loc_i]))
        loc_i += 1
    endwhile
EndFunction

Function _UpdateGagExpSliders()
    Faction[] loc_set = _GetGagExpSet()
    int loc_i = 0
    while loc_i < loc_set.length
        ;ConsoleUtil.PrintMessage(_GagExp[loc_i] + " = " + _TargetActor.GetFactionRank(loc_set[loc_i]))
        SetSliderParameters(_GagExp[loc_i], -1, 100, 1, _TargetActor.GetFactionRank(loc_set[loc_i]))
        loc_i += 1
        Utility.waitMenuMode(0.05)
    endwhile
EndFunction

Faction[] Function _GetGagExpSet(int aiSet = -1)
    Int loc_set = _GagExpSet
    if aiSet >= 0
        loc_set = aiSet
    endif
    if loc_set == 0
        return libs.ExpLibs.PhonemeModifierFactions
    elseif loc_set == 1
        return libs.ExpLibs.PhonemeModifierFactions_Large
    elseif loc_set == 2
        return libs.ExpLibs.PhonemeModifierFactions_Ring
    elseif loc_set == 3
        return libs.ExpLibs.PhonemeModifierFactions_Bit
    elseif loc_set == 4
        return libs.ExpLibs.PhonemeModifierFactions_Panel
    endif
EndFunction

String Function _GetGagExpSetKey(int aiSet = -1)
    Int loc_set = _GagExpSet
    if aiSet >= 0
        loc_set = aiSet
    endif
    if loc_set == 0
        return "GagExprSmall_"
    elseif loc_set == 1
        return "GagExprLarge_"
    elseif loc_set == 2
        return "GagExprRing_"
    elseif loc_set == 3
        return "GagExprBit_"
    elseif loc_set == 4
        return "GagExprPanel_"
    endif
EndFunction

Int Function _GetGagSetsNum()
    return 5
EndFunction

Function _CheckGagExpSliders(String asMorph, Float afValue)
    int loc_i = _GagExp.find(asMorph)
    if loc_i >= 0
        Faction[] loc_set = _GetGagExpSet()
        Faction loc_faction = loc_set[loc_i]
        _TargetActor.SetFactionRank(loc_faction,Round(afValue))
        _UpdateGagExpression()
    endif
EndFunction

Int Function Round(Float afVal)
    return Math.Floor(afVal + 0.5)
EndFunction

Function OnUpdate()
    _UpdateGagExpression()
    if _GagExpShow && UI.IsMenuOpen("RaceSex Menu")
        RegisterForSingleUpdate(0.5)
    endif
EndFunction

Event OnInitializeMenu(Actor player, ActorBase playerBase)
    _UpdateMorphs()
EndEvent

Event OnResetMenu(Actor player, ActorBase playerBase)
    _UpdateMorphs(true)
EndEvent

Function _SaveGagMorphs()
    int loc_i = _GetGagSetsNum()
    while loc_i
        loc_i -= 1
        Faction[] loc_set = _GetGagExpSet(loc_i)
        int loc_x = loc_set.length
        while loc_x
            loc_x -= 1
            Faction loc_expr = loc_set[loc_x]
            String  loc_key  = _GetGagExpSetKey(loc_i) + loc_x
            Int loc_stregnth = _TargetActor.GetFactionRank(loc_expr)
            NiOverride.SetBodyMorph(_TargetActor, loc_key, "DeviousDevices", loc_stregnth + 1)
        endwhile
    endwhile
EndFunction

Function _LoadGagMorphs()
    int loc_i = _GetGagSetsNum()
    while loc_i
        loc_i -= 1
        Faction[] loc_set = _GetGagExpSet(loc_i)
        int loc_x = loc_set.length
        while loc_x
            loc_x -= 1
            Faction loc_expr = loc_set[loc_x]
            String  loc_key  = _GetGagExpSetKey(loc_i) + loc_x
            Int loc_stregnth = Round(NiOverride.GetBodyMorph(_TargetActor, loc_key, "DeviousDevices")) - 1
            _TargetActor.SetFactionRank(loc_expr,loc_stregnth)
        endwhile
    endwhile
    _UpdateGagExpSliders()
    _UpdateGagExpression(true)
EndFunction

Function _UpdateMorphs(Bool abLoadGagExpr = False)
    if abLoadGagExpr
        _LoadGagMorphs()
    else
        _UpdateGagExpression(true)
    endif
EndFunction