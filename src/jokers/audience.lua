local function count_kings()
    local kings = 0

    for _, playing_card in ipairs(G.playing_cards or {}) do
        if playing_card.base.value == 'King' or playing_card.base.id == 13 then
            kings = kings + 1
        end
    end

    return kings
end

local function update_audience(card)
    if not G.hand or not card.ability or not card.ability.extra then
        return
    end

    local extra = card.ability.extra
    local old_bonus = extra.applied_bonus or 0
    local new_bonus = 0

    if card.added_to_deck and not card.debuff then
        new_bonus = math.floor(count_kings() / 4)
    end

    local difference = new_bonus - old_bonus

    if difference ~= 0 then
        G.hand:change_size(difference)
        extra.applied_bonus = new_bonus
    end
end

SMODS.Joker({
    key = 'audience',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 0 },

    rarity = 2,
    cost = 6,
    
    config = {
        extra = {
            applied_bonus = 0
        }
    },

    loc_txt = {
        name = 'Audience',
        text = {
            'Gain {C:attention}+1{} Hand Size for',
            'every {C:attention}4 Kings{} in deck',
            '{C:inactive}Currently{} {C:attention}+#1#{} {C:inactive}Hand Size{}'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { math.floor(count_kings() / 4) }
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.applied_bonus = 0
        update_audience(card)
    end,

    remove_from_deck = function(self, card, from_debuff)
        local extra = card.ability.extra
        local old_bonus = extra.applied_bonus or 0

        if old_bonus ~= 0 and G.hand then
            G.hand:change_size(-old_bonus)
        end

        extra.applied_bonus = 0
    end,

    update = function(self, card, dt)
        update_audience(card)
    end
})