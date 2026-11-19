SMODS.Joker({
    key = 'picnic_basket',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.remove_playing_cards
            and not context.blueprint
            and context.removed
            and #context.removed > 0 then

            local free_slots = G.consumeables.config.card_limit
                - (#G.consumeables.cards + G.GAME.consumeable_buffer)
            local to_create = math.min(#context.removed, free_slots)

            if to_create > 0 then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + to_create

                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _ = 1, to_create do
                            SMODS.add_card({ set = 'Tarot', key_append = 'aws_picnic_basket' })
                        end
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))

                return {
                    message = localize({ type = 'variable', key = 'aws_plus_tarots', vars = { to_create } }),
                    colour = G.C.PURPLE
                }
            end
        end
    end
})
