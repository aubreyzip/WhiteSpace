SMODS.Joker({
    key = 'blackjack',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    config = {
        extra = {
            triggered = false
        }
    },

    loc_txt = {
        name = 'Blackjack',
        text = {
            'Earn {C:money}$5{} if first hand',
            'sum totals {C:attention}21{}',
            '{C:inactive}Including non-scoring cards{}'
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.triggered = false
        end

        if context.after
            and context.main_eval
            and not context.blueprint
            and not card.ability.extra.triggered then

            card.ability.extra.triggered = true

            local total = 0
            local aces = 0

            for _, playing_card in ipairs(context.full_hand or {}) do
                local value = playing_card.base.value
                local id = playing_card.base.id

                if value == 'Ace' then
                    total = total + 11
                    aces = aces + 1
                elseif id >= 11 then
                    total = total + 10
                else
                    total = total + id
                end
            end

            while total > 21 and aces > 0 do
                total = total - 10
                aces = aces - 1
            end

            if total == 21 then
                ease_dollars(5)

                return {
                    message = 'Blackjack!',
                    colour = G.C.MONEY
                }
            end
        end
    end
})