local function get_extra(self, card)
    return type(card.ability.extra) == 'table' and card.ability.extra or self.config.extra
end

local function current_x_mult(extra)
    local dollars = G.GAME and G.GAME.dollars or 0
    local steps = math.max(0, math.floor((extra.dollar_threshold - dollars) / extra.dollar_step))
    return 1 + steps * extra.x_mult_mod
end

SMODS.Joker({
    key = 'delinquent',
    atlas = "aws_delinquent_animation",
    pos = { x = 0, y = 0 },
    sprite_args = {
        frames = 4,
        fps = 4
    },

    rarity = 3,
    cost = 8,

    config = {
        extra = {
            x_mult_mod = 0.5,
            dollar_step = 5,
            dollar_threshold = 25
        }
    },

    loc_vars = function(self, info_queue, card)
        local extra = get_extra(self, card)
        return {
            vars = {
                extra.x_mult_mod,
                extra.dollar_step,
                extra.dollar_threshold,
                current_x_mult(extra)
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local x_mult = current_x_mult(get_extra(self, card))

            if x_mult > 1 then
                return {
                    x_mult = x_mult
                }
            end
        end
    end
})
