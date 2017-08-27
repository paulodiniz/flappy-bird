module Model exposing (..)


type alias Game =
    { bird : Bird
    , pipes : List Pipe
    , windowDimensions : ( Int, Int )
    , state : GameState
    , score : Int
    }


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type alias Pipe =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    , direction: Direction
    , passed : Bool
    }

type Direction = Up | Down

type GameState
    = Play
    | Start
    | GameOver


initialBird : Bird
initialBird =
    { x = -150
    , y = 20
    , vx = 2
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
    , score = 0
    }
