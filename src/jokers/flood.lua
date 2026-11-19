SMODS.Joker({
    key = 'flood',
    atlas = 'aws_placeholders',
    pos = { x = 1, y = 0 },

    rarity = 2,
    cost = 5,

    config = {
        extra = {
            chip_mod = 20
        }
    },

    loc_vars = function(self, info_queue, card)
        local starting_size = G.GAME and G.GAME.starting_deck_size or 52
        local current_size = G.playing_cards and #G.playing_cards or starting_size
        local chips = math.max(0, starting_size - current_size) * card.ability.extra.chip_mod

        return {
            vars = {
                card.ability.extra.chip_mod,
                starting_size,
                chips
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local starting_size = G.GAME.starting_deck_size or 52
            local current_size = #G.playing_cards
            local chips = math.max(0, starting_size - current_size) * card.ability.extra.chip_mod

            if chips > 0 then
                return {
                    chips = chips
                }
            end
        end
    end
})
