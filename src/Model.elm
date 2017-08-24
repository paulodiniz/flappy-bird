module Model exposing (..)


type alias Game =
    { bird : Bird
    , pipes : List Pipe
    , windowDimensions : ( Int, Int )
    , state : GameState
    }


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type alias Pipe =
    { height : Float
    , passageSize : Float
    , passed : Bool
    , x : Float
    }


type GameState
    = Play
    | Start
    | GameOver


initialBird : Bird
initialBird =
    { x = -150
    , y = 20
    , vx = 0
    , vy = 0
    }


( gameWidth, gameHeight ) =
    ( 600, 400 )


initialGame : Game
initialGame =
    { bird = initialBird
    , pipes = []
    , windowDimensions = ( gameWidth, gameHeight )
    , state = Start
    }
