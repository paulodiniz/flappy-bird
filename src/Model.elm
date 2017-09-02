module Model exposing (..)


import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Msg

type alias Game =
    { bird : Bird
    , pipes : List Pipe
    , windowDimensions : ( Int, Int )
    , state : GameState
    , score : Int
    , player : Player
    , showDialog : Bool
    , phxSocket : Phoenix.Socket.Socket Msg.Msg
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

type Player = Anonymous | String

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
    , player = Anonymous
    , showDialog = True
    , phxSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
    }
