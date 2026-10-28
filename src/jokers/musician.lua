SMODS.Joker({
    key = 'musician',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 2,

    blueprint_compat = false,

    config = {
        extra = {
            odds = 8,
            big_dollars = 10,
            dollars = 1
        }
    },

    loc_txt = {
        name = 'Musician',
        text = {
            '{C:green}#1# in #2#{} chance to earn',
            '{C:money}$#3#{} at end of round,',
            'otherwise earn {C:money}$#4#{}'
        }
    },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(
            card,
            1,
            card.ability.extra.odds,
            'aws_musician'
        )
        return {
            vars = {
                numerator,
                denominator,
                card.ability.extra.big_dollars,
                card.ability.extra.dollars
            }
        }
    end,

    -- Paid once per round in the cash out screen, like Golden Joker
    calc_dollar_bonus = function(self, card)
        if SMODS.pseudorandom_probability(card, 'aws_musician', 1, card.ability.extra.odds, 'aws_musician') then
            return card.ability.extra.big_dollars
        end
        return card.ability.extra.dollars
    end
})
