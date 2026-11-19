SMODS.Joker({
    key = 'hopeker',
    atlas = 'aws_hopeker',
    pos = { x = 0, y = 0 },

    rarity = 3,
    cost = 7,

    blueprint_compat = false,
    eternal_compat = false,

    config = {
        extra = {
            used = false
        }
    },

    calculate = function(self, card, context)
        if context.end_of_round
            and context.game_over
            and context.main_eval
            and not context.blueprint
            and not card.ability.extra.used then

            card.ability.extra.used = true

            local jokers = G.jokers.cards
            local right_joker = nil

            for i, joker in ipairs(jokers) do
                if joker == card then
                    right_joker = jokers[i + 1]
                    break
                end
            end

            if right_joker and not right_joker.edition then
                local edition = SMODS.poll_edition(
                    {
                        key = 'aws_hopeker',
                        no_negative = false,
                        guaranteed = true
                    }
                )

                if edition then
                    right_joker:set_edition(edition, true)
                end
            end

            -- Flash the score display and destroy this card, like Mr. Bones
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    return true
                end
            }))
            SMODS.destroy_cards(card)

            return {
                saved = 'aws_saved_by_hopeker',
                message = 'Hopium!',
                colour = G.C.GREEN
            }
        end
    end
})