type
    Probability* = tuple
        oftenCeil, rarelyFloor: float
        ## Letter type probability floor and ceiling (between is default)
        
        formables: float
        ## Probability to choose a formable over simply generate next letter

const
    defaultProbability*: Probability = (
        oftenCeil: 0.5,
        rarelyFloor: 0.2,

        formables: 0.2
    )
    ## Default probabilites, if no custom config loaded

