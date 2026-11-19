SMODS.Joker({
    key = 'caffeine',
    atlas = 'aws_caffeine',
    pos = { x = 0, y = 0},

    rarity = 2,
    cost = 6,

    config = {
        extra = {
            odds = 3
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                SMODS.get_probability_vars(
                    card,
                    1,
                    card.ability.extra.odds,
                    'aws_caffeine'
                )
            }
        }
    end,

    calculate = function(self, card, context)
        if context.repetition
            and context.cardarea == G.play
            and not context.retrigger_joker then

            if SMODS.pseudorandom_probability(card, 'aws_caffeine', 1, card.ability.extra.odds, 'aws_caffeine') then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end
    end
})