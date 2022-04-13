export BOARD_NAMES, BOARD_TO_W_BAND_POL, W_BAND_POL_TO_BOARD
export polarimeter_list

const BOARD_NAMES = Symbol[:B, :G, :I, :O, :R, :V, :Y]
const BOARD_TO_W_BAND_POL = Dict{Symbol,Symbol}([
    (:Y, :W1),
    (:O, :W2),
    (:R, :W3),
    (:V, :W4),
    (:B, :W5),
    (:G, :W6),
    # I is missing because it has no associated W-band polarimeter
])

const W_BAND_POL_TO_BOARD = Dict(value => key for (key, value) in BOARD_TO_W_BAND_POL)

function polarimeter_list(
    ;
    boards=BOARD_NAMES,
    qband=true,
    wband=true,
)

    startidx = qband ? 0 : 7
    endidx = wband ? 7 : 6

    result = []
    for curboard in boards
        for polidx in startidx:endidx
            ((curboard == :I) && (polidx == 7)) && continue

            if polidx != 7
                polname = "$(curboard)$(polidx)"
            else
                polname = BOARD_TO_W_BAND_POL[curboard]
            end
            push!(result, Symbol(polname))
        end
    end

    result
end
