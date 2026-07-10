//TESH.scrollpos=0
//TESH.alwaysfold=0
// 英雄开局自定义等级
// 移植: 改 SetHeroLevel 的第三个参数为目标等级

function Trig_HeroLevel_Actions takes nothing returns nothing
    local integer i = 0
    local unit u
    local group g = CreateGroup()

    loop
        exitwhen i > 15
        call GroupEnumUnitsOfPlayer(g, Player(i), null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if IsUnitType(u, UNIT_TYPE_HERO) then
                call SetHeroLevel(u, 5, false)
            endif
        endloop
        set i = i + 1
    endloop

    call DestroyGroup(g)
    set g = null
    set u = null
endfunction

function InitTrig_HeroLevel takes nothing returns nothing
    local trigger trg = CreateTrigger()
    call TriggerRegisterTimerEvent(trg, 0.00, false)
    call TriggerAddAction(trg, function Trig_HeroLevel_Actions)
    set trg = null
endfunction
