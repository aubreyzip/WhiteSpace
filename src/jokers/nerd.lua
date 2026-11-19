
SMODS.Joker({
    key = "nerd",
    atlas = "aws_placeholders",
    pos = { x = 0, y = 0 },
    
    rarity = 1,
    cost = 6,

    config = {
        extra = {
            odds = 2
        }
    },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(
            card,
            1,
            card.ability.extra.odds,
            "aws_nerd"
        )
        return {
            vars = {
                numerator,
                denominator
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.hand
            and not context.end_of_round
            and context.other_card:get_id() >= 2
            and context.other_card:get_id() <= 10
        then
            if SMODS.pseudorandom_probability(
                card,
                "aws_nerd",
                1,
                card.ability.extra.odds,
                "aws_nerd"
            ) then
                return {
                    dollars = 1,
                    card = context.other_card
                }
            end
        end
    end
})