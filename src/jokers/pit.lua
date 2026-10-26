SMODS.Joker({
    key = 'pit',
    atlas = 'aws_placeholders',
    pos = { x = 2, y = 0 },

    rarity = 3,
    cost = 5,

    blueprint_compat = true,

    config = {
        extra = {
            x_mult = 1.5
        }
    },

    loc_txt = {
        name = 'Pit',
        text = {
            'Each played card that',
            'does not score gives',
            '{X:mult,C:white}X#1#{} Mult'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.x_mult }
        }
    end,

    calculate = function(self, card, context)
        -- SMODS scores each non-scoring played card once with cardarea 'unscored'
        if context.individual and context.cardarea == 'unscored' then
            return {
                xmult = card.ability.extra.x_mult
            }
        end
    end
})
