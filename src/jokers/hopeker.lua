SMODS.Joker({
    key = 'hopeker',
    atlas = 'aws_hopeker',
    pos = { x = 0, y = 0 },

    rarity = 3,
    cost = 7,

    config = {
        extra = {
            used = false
        }
    },

    loc_txt = {
        name = 'Hopeker',
        text = {
            'When defeated, prevent loss',
            'and give the Joker to the right',
            'a random {C:dark_edition}Edition{}',
            '{C:inactive}(Inject hopium)'
        }
    },

    calculate = function(self, card, context)
        if context.game_over
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

            return {
                saved = true,
                message = 'Hopium!',
                colour = G.C.GREEN
            }
        end
    end
})