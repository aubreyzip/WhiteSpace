SMODS.Joker({
    key = 'picnic_basket',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    blueprint_compat = true,

    loc_txt = {
        name = 'Picnic Basket',
        text = {
            'Create a random {C:tarot}Tarot{} card',
            'when a playing card is destroyed'
        }
    },

    calculate = function(self, card, context)
        if context.remove_playing_cards
            and not context.blueprint
            and context.removed
            and #context.removed > 0 then

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                func = function()
                    if G.consumeables
                        and #G.consumeables.cards < G.consumeables.config.card_limit then

                        card_eval_status_text(
                            card,
                            'extra',
                            nil,
                            nil,
                            nil,
                            {
                                message = localize('k_plus_tarot'),
                                colour = G.C.PURPLE
                            }
                        )

                        local tarot = create_card(
                            'Tarot',
                            G.consumeables,
                            nil,
                            nil,
                            nil,
                            nil,
                            nil,
                            'aws_picnic_basket'
                        )

                        tarot:add_to_deck()
                        G.consumeables:emplace(tarot)
                    end

                    return true
                end
            }))
        end
    end
})