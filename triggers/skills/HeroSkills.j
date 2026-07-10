//TESH.scrollpos=0
//TESH.alwaysfold=0
// 八面龙卷风 (A001) + 雷霆之怒 (A000)
// 移植: 改 A001/A000 为目标技能ID
// Ctrl+B 创建变量: BM_Hash (哈希表), BM_Bolt (闪电)

function Trig_HeroSkills_D2R takes real deg returns real
    return deg * 0.0174533
endfunction

function Trig_HeroSkills_TornadoTick takes nothing returns nothing
    local timer tm = GetExpiredTimer()
    local integer hid = GetHandleId(tm)
    local unit caster = LoadUnitHandle(udg_BM_Hash, hid, 0)
    local real cx = LoadReal(udg_BM_Hash, hid, 1)
    local real cy = LoadReal(udg_BM_Hash, hid, 2)
    local real angle = LoadReal(udg_BM_Hash, hid, 3)
    local integer step = LoadInteger(udg_BM_Hash, hid, 4) + 1
    local player owner = LoadPlayerHandle(udg_BM_Hash, hid, 6)
    local integer maxS = LoadInteger(udg_BM_Hash, hid, 7)
    local real dist
    local real x
    local real y
    local group g
    local unit u

    if step > maxS then
        call FlushChildHashtable(udg_BM_Hash, hid)
        call DestroyTimer(tm)
        set caster = null
        set owner = null
        set tm = null
        return
    endif

    call SaveInteger(udg_BM_Hash, hid, 4, step)
    set dist = step * 50.0
    set x = cx + dist * Cos(angle)
    set y = cy + dist * Sin(angle)
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Tornado\\TornadoElemental.mdl", x, y))

    set g = CreateGroup()
    call GroupEnumUnitsInRange(g, x, y, 130.0, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)
        if IsUnitEnemy(u, owner) and GetUnitState(u, UNIT_STATE_LIFE) > 0.405 then
            if not HaveSavedBoolean(udg_BM_Hash, hid, GetHandleId(u)) then
                call SaveBoolean(udg_BM_Hash, hid, GetHandleId(u), true)
                call UnitDamageTarget(caster, u, 100.0, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
        endif
    endloop
    call DestroyGroup(g)

    set caster = null
    set owner = null
    set g = null
    set u = null
    set tm = null
endfunction

function Trig_HeroSkills_BoltCleanup takes nothing returns nothing
    if udg_BM_Bolt != null then
        call DestroyLightning(udg_BM_Bolt)
        set udg_BM_Bolt = null
    endif
    call DestroyTimer(GetExpiredTimer())
endfunction

function Trig_HeroSkills_BoltTick takes nothing returns nothing
    local timer tm = GetExpiredTimer()
    local integer hid = GetHandleId(tm)
    local real tx = LoadReal(udg_BM_Hash, hid, 0)
    local real ty = LoadReal(udg_BM_Hash, hid, 1)
    local timer dt = CreateTimer()

    set udg_BM_Bolt = AddLightningEx("FORK", true, tx, ty, 600.0, tx, ty, 0)
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\ThunderClap\\ThunderClapCaster.mdl", tx, ty))
    call TimerStart(dt, 0.30, false, function Trig_HeroSkills_BoltCleanup)

    call FlushChildHashtable(udg_BM_Hash, hid)
    call DestroyTimer(tm)

    set tm = null
    set dt = null
endfunction

function Trig_HeroSkills_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local integer abi = GetSpellAbilityId()
    local real cx
    local real cy
    local real tx
    local real ty
    local integer i
    local timer tm
    local integer hid
    local group g
    local unit u

    if abi == 'A001' then
        set cx = GetUnitX(caster)
        set cy = GetUnitY(caster)
        set i = 0
        loop
            exitwhen i >= 8
            set tm = CreateTimer()
            set hid = GetHandleId(tm)
            call SaveUnitHandle(udg_BM_Hash, hid, 0, caster)
            call SaveReal(udg_BM_Hash, hid, 1, cx)
            call SaveReal(udg_BM_Hash, hid, 2, cy)
            call SaveReal(udg_BM_Hash, hid, 3, Trig_HeroSkills_D2R(i * 45.0))
            call SaveInteger(udg_BM_Hash, hid, 4, 0)
            call SavePlayerHandle(udg_BM_Hash, hid, 6, GetOwningPlayer(caster))
            call SaveInteger(udg_BM_Hash, hid, 7, R2I(1000.0 / 50.0))
            call TimerStart(tm, 0.03, true, function Trig_HeroSkills_TornadoTick)
            set i = i + 1
        endloop

    elseif abi == 'A000' then
        set tx = GetSpellTargetX()
        set ty = GetSpellTargetY()
        call IssueImmediateOrder(caster, "stop")

        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, tx, ty, 300.0, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if IsUnitEnemy(u, GetOwningPlayer(caster)) and GetUnitState(u, UNIT_STATE_LIFE) > 0.405 then
                call UnitDamageTarget(caster, u, 200.0, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
            endif
        endloop
        call DestroyGroup(g)

        set tm = CreateTimer()
        set hid = GetHandleId(tm)
        call SaveReal(udg_BM_Hash, hid, 0, tx)
        call SaveReal(udg_BM_Hash, hid, 1, ty)
        call TimerStart(tm, 0.05, false, function Trig_HeroSkills_BoltTick)
    endif

    set caster = null
    set tm = null
    set g = null
    set u = null
endfunction

function InitTrig_HeroSkills takes nothing returns nothing
    local trigger trg = CreateTrigger()
    local integer i = 0

    set udg_BM_Hash = InitHashtable()

    loop
        exitwhen i > 15
        call TriggerRegisterPlayerUnitEvent(trg, Player(i), EVENT_PLAYER_UNIT_SPELL_CAST, null)
        set i = i + 1
    endloop
    call TriggerAddAction(trg, function Trig_HeroSkills_Actions)
    set trg = null
endfunction
