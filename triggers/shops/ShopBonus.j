//TESH.scrollpos=0
//TESH.alwaysfold=0
// 商店购买赠送攻击之爪
// 移植: 修改 sid 列表为目标商店ID (全小写, Ctrl+D 查看)
//      可改 'rat6' 为其他物品ID

function Trig_ShopBonus_Actions takes nothing returns nothing
    local unit seller = GetSellingUnit()
    local unit buyer = GetBuyingUnit()
    local integer sid = GetUnitTypeId(seller)

    if buyer != null then
        if sid == 'hvlt' or sid == 'hars' or sid == 'h000' then
            call UnitAddItem(buyer, CreateItem('rat6', GetUnitX(buyer), GetUnitY(buyer)))
        endif
    endif

    set seller = null
    set buyer = null
endfunction

function InitTrig_ShopBonus takes nothing returns nothing
    local trigger trg = CreateTrigger()
    call TriggerRegisterPlayerUnitEvent(trg, Player(0), EVENT_PLAYER_UNIT_SELL_ITEM, null)
    call TriggerAddAction(trg, function Trig_ShopBonus_Actions)
    set trg = null
endfunction
