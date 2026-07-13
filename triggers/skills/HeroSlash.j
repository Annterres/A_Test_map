//TESH.scrollpos=0
//TESH.alwaysfold=0
// ====== 闪电旋风劈 (A002) ======
// 效果: 对目标单位施放 → 暴击跳劈动画 → 抛物线滑到目标身后 → 100伤害
// 依赖: 物体编辑器已定义 A002 (基于 ANcl, 单位目标, 施法距离800)
//       全局变量 BM_Hash (哈希表) — 如未定义请在 Ctrl+B 中创建
// 移植: 修改 A002 为目标技能ID, 调整 伤害/距离/速度 参数

function Trig_HeroSlash_SlashTick takes nothing returns nothing
    local timer tm = GetExpiredTimer()
    local integer hid = GetHandleId(tm)
    local unit caster = LoadUnitHandle(udg_BM_Hash, hid, 0)
    local unit target = LoadUnitHandle(udg_BM_Hash, hid, 1)
    local real startX = LoadReal(udg_BM_Hash, hid, 2)
    local real startY = LoadReal(udg_BM_Hash, hid, 3)
    local real endX   = LoadReal(udg_BM_Hash, hid, 4)
    local real endY   = LoadReal(udg_BM_Hash, hid, 5)
    local integer step = LoadInteger(udg_BM_Hash, hid, 7) + 1
    local real progress
    local real curX
    local real curY
    local real curZ

    // 25步 × 0.03s = 0.75秒抛物线
    if step > 25 then
        // 落点: 目标身后
        call SetUnitX(caster, endX)
        call SetUnitY(caster, endY)
        call SetUnitFlyHeight(caster, 0.0, 0.0)
        call SetUnitAnimation(caster, "stand")
        call UnitRemoveAbility(caster, 'Amrf')

        // 受击特效 + 100伤害
        if target != null and GetUnitState(target, UNIT_STATE_LIFE) > 0.405 then
            call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\HydraliskImpact\\HydraliskImpact.mdl", GetUnitX(target), GetUnitY(target)))
            call UnitDamageTarget(caster, target, 100.0, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null)
        endif

        call FlushChildHashtable(udg_BM_Hash, hid)
        call DestroyTimer(tm)
        set caster = null
        set target = null
        set tm = null
        return
    endif

    call SaveInteger(udg_BM_Hash, hid, 7, step)
    set progress = I2R(step) / 25.0

    // 线性插值 X/Y
    set curX = startX + (endX - startX) * progress
    set curY = startY + (endY - startY) * progress
    // 抛物线高度: maxH=400, 公式 4*maxH*t*(1-t)
    set curZ = 800.0 * progress * (1.0 - progress)

    call SetUnitX(caster, curX)
    call SetUnitY(caster, curY)
    call SetUnitFlyHeight(caster, curZ, 0.0)

    set caster = null
    set target = null
    set tm = null
endfunction

// 延迟一帧启动: 等技能动画状态机释放后再设 slam + 开始飞行
function Trig_HeroSlash_DelayStart takes nothing returns nothing
    local timer delayTm = GetExpiredTimer()
    local integer dHid = GetHandleId(delayTm)
    local unit caster = LoadUnitHandle(udg_BM_Hash, dHid, 0)
    local unit target = LoadUnitHandle(udg_BM_Hash, dHid, 1)
    local real cx     = LoadReal(udg_BM_Hash, dHid, 2)
    local real cy     = LoadReal(udg_BM_Hash, dHid, 3)
    local real tx     = LoadReal(udg_BM_Hash, dHid, 4)
    local real ty     = LoadReal(udg_BM_Hash, dHid, 5)
    local timer flightTm
    local integer fHid

    // 安全设置暴击跳劈动画
    call SetUnitAnimation(caster, "slam")

    // 启动抛物线飞行计时器
    set flightTm = CreateTimer()
    set fHid = GetHandleId(flightTm)
    call SaveUnitHandle(udg_BM_Hash, fHid, 0, caster)
    call SaveUnitHandle(udg_BM_Hash, fHid, 1, target)
    call SaveReal(udg_BM_Hash, fHid, 2, cx)
    call SaveReal(udg_BM_Hash, fHid, 3, cy)
    call SaveReal(udg_BM_Hash, fHid, 4, tx)
    call SaveReal(udg_BM_Hash, fHid, 5, ty)
    call SaveInteger(udg_BM_Hash, fHid, 7, 0)
    call TimerStart(flightTm, 0.03, true, function Trig_HeroSlash_SlashTick)

    // 清理延迟计时器
    call FlushChildHashtable(udg_BM_Hash, dHid)
    call DestroyTimer(delayTm)
    set delayTm = null
    set caster = null
    set target = null
    set flightTm = null
endfunction

function Trig_HeroSlash_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local unit target
    local real cx
    local real cy
    local real tx
    local real ty
    local real angle
    local timer delayTm
    local integer dHid

    if GetSpellAbilityId() != 'A002' then
        set caster = null
        return
    endif

    set target = GetSpellTargetUnit()
    set cx = GetUnitX(caster)
    set cy = GetUnitY(caster)
    set tx = GetUnitX(target)
    set ty = GetUnitY(target)

    // 目标身后落点 (沿施法者→目标方向延伸150)
    set angle = Atan2(ty - cy, tx - cx)
    set tx = tx + 150.0 * Cos(angle)
    set ty = ty + 150.0 * Sin(angle)

    // 启用飞行高度 (Crow Form 技巧)
    call UnitAddAbility(caster, 'Amrf')
    call UnitRemoveAbility(caster, 'Amrf')

    // 0秒延迟: 等技能动画状态机释放后再设 slam, 避免冲突
    set delayTm = CreateTimer()
    set dHid = GetHandleId(delayTm)
    call SaveUnitHandle(udg_BM_Hash, dHid, 0, caster)
    call SaveUnitHandle(udg_BM_Hash, dHid, 1, target)
    call SaveReal(udg_BM_Hash, dHid, 2, cx)
    call SaveReal(udg_BM_Hash, dHid, 3, cy)
    call SaveReal(udg_BM_Hash, dHid, 4, tx)
    call SaveReal(udg_BM_Hash, dHid, 5, ty)
    call TimerStart(delayTm, 0.00, false, function Trig_HeroSlash_DelayStart)

    set caster = null
    set target = null
    set delayTm = null
endfunction

function InitTrig_HeroSlash takes nothing returns nothing
    local trigger trg = CreateTrigger()
    local integer i = 0

    // 确保哈希表已初始化 (兼容独立移植)
    if udg_BM_Hash == null then
        set udg_BM_Hash = InitHashtable()
    endif

    loop
        exitwhen i > 15
        call TriggerRegisterPlayerUnitEvent(trg, Player(i), EVENT_PLAYER_UNIT_SPELL_CAST, null)
        set i = i + 1
    endloop
    call TriggerAddAction(trg, function Trig_HeroSlash_Actions)
    set trg = null
endfunction
