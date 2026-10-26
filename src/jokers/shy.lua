SMODS.Joker({
    key = 'shy',
    atlas = 'aws_placeholders',
    pos = { x = 3, y = 0 },

    rarity = 4,
    cost = 20,

    blueprint_compat = true,

    config = {
        extra = {
            x_mult = 2
        }
    },

    loc_txt = {
        name = 'Shy',
        text = {
            'Each played {C:attention}Ace{} and {C:attention}10{}',
            'gives {X:mult,C:white}X#1#{} Mult when scored'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.x_mult }
        }
    end,

    calculate = function(self, card, context)
        -- Runs once per scoring card, and again for each retrigger
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 14 or id == 10 then
                return {
                    xmult = card.ability.extra.x_mult
                }
            end
        end
    end
})
