SMODS.Joker({
    key = 'oops_all_ones',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 0 },

    rarity = 2,
    cost = 4,

    blueprint_compat = false,

    loc_txt = {
        name = 'Oops, All 1\'s!',
        text = {
            'Halves all {C:attention}listed',
            '{C:green,E:1,S:1.1}probabilities',
            '{C:inactive}(ex: {C:green}1 in 2{C:inactive} -> {C:green}1 in 4{C:inactive})'
        }
    },

    -- Mirrors vanilla Oops! All 6s, which scales G.GAME.probabilities the same way.
    -- This also covers Jokers that roll against G.GAME.probabilities.normal directly.
    -- Both hooks also run when the card is debuffed / undebuffed.
    add_to_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v / 2
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v * 2
        end
    end,

    calculate = function(self, card, context)
        -- SMODS multiplies listed numerators by G.GAME.probabilities.normal after
        -- this context, which halves them. Doubling both sides here moves that
        -- halving onto the denominator, so 1 in 2 shows as 1 in 4 (not 0.5 in 2).
        if context.mod_probability and not context.blueprint then
            return {
                numerator = context.numerator * 2,
                denominator = context.denominator * 2
            }
        end
    end
})
