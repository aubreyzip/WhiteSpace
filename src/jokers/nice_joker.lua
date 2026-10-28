SMODS.Joker({
    key = 'nice_joker',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    blueprint_compat = true,

    config = {
        extra = {
            mult = 4,
            chips = 20
        }
    },

    loc_txt = {
        name = 'Nice Joker',
        text = {
            'Each played {C:attention}6{} or {C:attention}9{} gives',
            '{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips',
            'when scored'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                card.ability.extra.chips
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 6 or id == 9 then
                return {
                    chips = card.ability.extra.chips,
                    mult = card.ability.extra.mult
                }
            end
        end
    end
})
