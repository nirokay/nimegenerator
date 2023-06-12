import std/options

type
    Probability* = tuple
        oftenCeil, rarelyFloor: float
        ## Letter type probability floor and ceiling (between is default)
        
        formables: float
        ## Probability to choose a formable over simply generate next letter

    GenerationRules* = object
        probability*: Probability
        generationCicles*: tuple[min, max: int]
        ## Generation cicles are NOT the length of a string, as some cicles may
        ## result in the addition of multiple chars!
        maxCharsWithoutVowel*: Option[int]



const    
    defaultGenerationRules* = GenerationRules(
        probability: (
            oftenCeil: 0.6,
            rarelyFloor: 0.2,
            formables: 0.1
        ),
        generationCicles: (
            min: 2,
            max: 5
        ),
        maxCharsWithoutVowel: some 4
    )

var rules*: GenerationRules = defaultGenerationRules

