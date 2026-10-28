SMODS.Joker({
    key = 'pristine',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 5,

    blueprint_compat = true,

    config = {
        extra = {
            chips = 25
        }
    },

    loc_txt = {
        name = 'Pristine',
        text = {
            'Each played card with no',
            '{C:attention}Enhancement{} gives',
            '{C:chips}+#1#{} Chips when scored'
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.chips }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and not next(SMODS.get_enhancements(context.other_card)) then

            return {
                chips = card.ability.extra.chips
            }
        end
    end
})
