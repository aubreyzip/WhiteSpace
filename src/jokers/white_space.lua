-- White Space copies a Joker the player doesn't own. Steamodded's copy mechanism
-- (SMODS.blueprint_effect) needs a real Card to calculate, so White Space keeps a
-- hidden "phantom" Card of the chosen Joker that never enters a CardArea.

-- Copying Jokers would copy nothing (or loop) from outside the Joker area
local excluded_keys = {
    j_aws_white_space = true,
    j_blueprint = true,
    j_brainstorm = true
}

local function is_copier(center)
    if excluded_keys[center.key] then return true end
    if type(center.attributes) == 'table' then
        for _, attribute in pairs(center.attributes) do
            if attribute == 'copying' then return true end
        end
    end
    return false
end

local function is_owned(key)
    return next(SMODS.find_card(key, true)) ~= nil
end

local function get_eligible_keys()
    local keys = {}
    for _, center in ipairs(G.P_CENTER_POOLS.Joker) do
        if center.blueprint_compat
            and center.unlocked ~= false
            and not G.GAME.banned_keys[center.key]
            and not is_copier(center)
            and not is_owned(center.key) then
            keys[#keys + 1] = center.key
        end
    end
    return keys
end

-- Creating or removing a Card toggles G.GAME.used_jokers, which would hide
-- the copied Joker from (or leak it into) the shop. Keep the flag untouched.
local function preserve_used_flag(key, func)
    local used = G.GAME.used_jokers[key]
    local ret = func()
    G.GAME.used_jokers[key] = used
    return ret
end

local function remove_phantom(card)
    local phantom = card.aws_phantom
    card.aws_phantom = nil
    if phantom and not phantom.removed then
        preserve_used_flag(phantom.config.center.key, function()
            phantom:remove()
        end)
    end
end

local function create_phantom(key)
    return preserve_used_flag(key, function()
        local phantom = Card(0, 0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS[key], {
            bypass_discovery_center = true,
            bypass_discovery_ui = true
        })
        phantom.states.visible = false
        phantom.states.collide.can = false
        phantom.states.hover.can = false
        phantom.states.drag.can = false
        return phantom
    end)
end

local function pick_copied_joker(card)
    remove_phantom(card)

    local keys = get_eligible_keys()
    card.ability.extra.copied_key = (#keys > 0) and pseudorandom_element(keys, pseudoseed('aws_white_space')) or nil
end

-- The phantom isn't saved, so rebuild it lazily (e.g. after loading a run)
local function get_phantom(card)
    local key = card.ability.extra.copied_key
    if not key or not G.P_CENTERS[key] then
        remove_phantom(card)
        return nil
    end

    -- The copied Joker destroyed itself (e.g. Gros Michel), so it stays gone this round
    if card.aws_phantom and (card.aws_phantom.removed or card.aws_phantom.getting_sliced) then
        card.aws_phantom = nil
        card.ability.extra.unsupported = true
        return nil
    end

    if not card.aws_phantom or card.aws_phantom.config.center.key ~= key then
        remove_phantom(card)
        card.aws_phantom = create_phantom(key)
    end
    return card.aws_phantom
end

-- SMODS.blueprint_effect, but an erroring copied Joker only disables the
-- copy for the rest of the round instead of crashing the game
local function safe_blueprint_effect(card, phantom, context)
    local old_blueprint = context.blueprint
    local old_blueprint_card = context.blueprint_card
    local old_copier = context.blueprint_copier
    local old_stack_size = context.blueprint_copiers_stack and #context.blueprint_copiers_stack

    local ok, ret = pcall(SMODS.blueprint_effect, card, phantom, context)
    if ok then return ret end

    context.blueprint = old_blueprint
    context.blueprint_card = old_blueprint_card
    context.blueprint_copier = old_copier
    if context.blueprint_copiers_stack then
        for i = #context.blueprint_copiers_stack, (old_stack_size or 0) + 1, -1 do
            table.remove(context.blueprint_copiers_stack, i)
        end
    end

    sendWarnMessage(('White Space failed to copy %s: %s'):format(tostring(phantom.config.center.key), tostring(ret)), 'WhiteSpace')
    card.ability.extra.unsupported = true
end

-- Credit effects the phantom returns about itself to White Space
local function redirect_to_copier(ret, card, phantom)
    while type(ret) == 'table' do
        for k, v in pairs(ret) do
            if v == phantom then ret[k] = card end
        end
        ret = ret.extra
    end
end

-- Calculates the phantom as if the player owned it, so effects guarded by
-- `not context.blueprint` (Vampire stripping enhancements, scaling Jokers
-- gaining value) still happen. Blueprint semantics would skip all of those.
local function owned_effect(card, phantom, context)
    -- Messages the phantom shows on itself (e.g. SMODS.scale_card) appear on White Space
    phantom:hard_set_T(card.T.x, card.T.y, card.T.w, card.T.h)

    local ok, ret, triggered = pcall(phantom.calculate_joker, phantom, context)
    if not ok then
        sendWarnMessage(('White Space failed to copy %s: %s'):format(tostring(phantom.config.center.key), tostring(ret)), 'WhiteSpace')
        card.ability.extra.unsupported = true
        return
    end

    redirect_to_copier(ret, card, phantom)
    return ret, triggered
end

SMODS.Joker({
    key = 'white_space',
    atlas = 'aws_white_space',
    pos = { x = 0, y = 0 },

    rarity = 2,
    cost = 6,

    blueprint_compat = true,

    config = {
        extra = {
            copied_key = nil,
            unsupported = false
        }
    },

    loc_txt = {
        name = 'White Space',
        text = {
            'Copies the ability of a random',
            '{C:attention}Joker{} you do not own',
            'Changes after each {C:attention}round{}',
            '{C:inactive}(Currently {C:attention}#1#{C:inactive})'
        }
    },

    loc_vars = function(self, info_queue, card)
        local key = card.ability.extra.copied_key
        local center = key and G.P_CENTERS[key]
        if not center then
            return { vars = { localize('k_none') } }
        end

        info_queue[#info_queue + 1] = center
        return {
            vars = { localize({ type = 'name_text', set = 'Joker', key = key }) }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff and not card.ability.extra.copied_key then
            pick_copied_joker(card)
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        remove_phantom(card)
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- starting_shop fires once after cashing out (not when reloading into the shop)
        if context.starting_shop and not context.blueprint then
            extra.unsupported = false
            pick_copied_joker(card)
            if extra.copied_key then
                SMODS.calculate_effect({
                    message = localize({ type = 'name_text', set = 'Joker', key = extra.copied_key }),
                    colour = G.C.GREY
                }, card)
            end
        end

        -- Guards against re-entering through a copy of this card
        if extra.unsupported or card.aws_calculating then return end

        local phantom = get_phantom(card)
        if not phantom or is_owned(extra.copied_key) then return end

        -- When White Space is itself being copied, copy the phantom like Blueprint
        -- would so the copied Joker's side effects don't happen twice
        card.aws_calculating = true
        local ret, triggered
        if context.blueprint then
            ret = safe_blueprint_effect(card, phantom, context)
        else
            ret, triggered = owned_effect(card, phantom, context)
        end
        card.aws_calculating = nil
        return ret, triggered
    end
})
