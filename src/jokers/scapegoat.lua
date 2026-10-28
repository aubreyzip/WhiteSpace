SMODS.Joker({
    key = 'scapegoat',
    atlas = 'aws_scapegoat',
    pos = { x = 0, y = 0 },

    rarity = 2,
    cost = 7,

    blueprint_compat = true,
    perishable_compat = false,

    config = {
        extra = {
            x_mult_mod = 0.25,
            shops = 0,
            bought_joker = false
        }
    },

    loc_txt = {
        name = 'Scapegoat',
        text = {
            'Gains {X:mult,C:white}X#1#{} Mult for each',
            'consecutive shop left',
            'without buying a {C:attention}Joker{}',
            '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)'
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return {
            vars = {
                extra.x_mult_mod,
                1 + extra.shops * extra.x_mult_mod
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.joker_main and extra.shops > 0 then
            return {
                xmult = 1 + extra.shops * extra.x_mult_mod
            }
        end

        if context.buying_card
            and not context.blueprint
            and context.card.ability.set == 'Joker' then

            extra.bought_joker = true

            -- Buying Scapegoat itself only stops its own shop from counting
            if context.card ~= card and extra.shops > 0 then
                extra.shops = 0
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
            end
        end

        if context.ending_shop and not context.blueprint then
            if extra.bought_joker then
                extra.bought_joker = false
                return
            end

            extra.shops = extra.shops + 1
            return {
                message = localize({
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { 1 + extra.shops * extra.x_mult_mod }
                }),
                colour = G.C.MULT
            }
        end
    end
})
