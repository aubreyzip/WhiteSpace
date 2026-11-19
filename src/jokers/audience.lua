local function count_kings()
    local kings = 0

    for _, playing_card in ipairs(G.playing_cards or {}) do
        if not SMODS.has_no_rank(playing_card) and playing_card:get_id() == 13 then
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

local function mark_dirty(card)
    card.aws_audience_dirty = true
end

SMODS.Joker({
    key = 'audience',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 0 },

    rarity = 2,
    cost = 6,

    blueprint_compat = false,

    config = {
        extra = {
            applied_bonus = 0
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

    calculate = function(self, card, context)
        if context.playing_card_added
            or context.remove_playing_cards
            or context.change_rank
            or context.setting_ability
            or context.setting_blind then
            mark_dirty(card)
        end
    end,

    update = function(self, card, dt)
        if not G.hand or not G.playing_cards then
            return
        end

        local deck_size = #G.playing_cards
        if card.aws_audience_dirty == false and card.aws_audience_deck_size == deck_size then
            return
        end

        card.aws_audience_dirty = false
        card.aws_audience_deck_size = deck_size
        update_audience(card)
    end
})
