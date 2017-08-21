module Main exposing (..)

import AnimationFrame
import Collage exposing (..)
import Color exposing (..)
import Element exposing (..)
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (..)


type alias Space =
    Bool


main : Program Never Game Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


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


init : ( Game, Cmd Msg )
init =
    ( initialGame, Cmd.none )



-- UPDATE


type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | GeneratePipe Time


update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case game.state of
        Play ->
            case msg of
                TimeUpdate dt ->
                    ( updateFlappy game, Cmd.none )

                KeyDown keyCode ->
                    ( { game | bird = jump game.bird }, Cmd.none )

                GeneratePipe _ ->
                    ( generateNewPipe game, Cmd.none )

        Start ->
            case msg of
                KeyDown keyCode ->
                    ( { game | state = Play }, Cmd.none )

                _ ->
                    ( game, Cmd.none )

        GameOver ->
            ( game, Cmd.none )


generateNewPipe : Game -> Game
generateNewPipe game =
    let
        newPipe =
            { height = 40
            , passageSize = 200
            , passed = False
            , x = 300
            }
    in
        { game | pipes = List.append game.pipes [ newPipe ] }


updateFlappy : Game -> Game
updateFlappy game =
    game
        |> gravity
        |> physics
        |> updatePipes
        |> checkCollisions


gravity : Game -> Game
gravity game =
    let
        bird =
            game.bird

        newBird =
            { bird
                | vy =
                    if bird.y > -(gameHeight / 2) then
                        bird.vy - gravityValue
                    else
                        0
            }
    in
        { game | bird = newBird }


physics : Game -> Game
physics game =
    let
        bird =
            game.bird

        newBird =
            if bird.y <= (gameHeight/2) then
                { bird | y = bird.y + bird.vy }
            else
                { bird | y = (gameHeight/2) }
    in
        { game | bird = newBird }


gravityValue : Float
gravityValue =
    0.45


jump : Bird -> Bird
jump bird =
    { bird | vy = 8 }


updatePipes : Game -> Game
updatePipes game =
    { game | pipes = List.map updatePipe game.pipes }


updatePipe : Pipe -> Pipe
updatePipe pipe =
    { pipe | x = pipe.x - 10 }


checkCollisions : Game -> Game
checkCollisions game =
    let
        bird =
            game.bird
    in
        if bird.y <= -(gameHeight / 2) then
            { game | state = GameOver }
        else
            game



-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every second GeneratePipe
        ]


pipeToForms : Pipe -> List Form
pipeToForms pipe =
    let
        pipeWidth =
            75

        pipeHeight =
            100
    in
        [ image pipeWidth pipeHeight "./src/pipe_down.png"
            |> toForm
            |> move ( pipe.x, pipe.height - gameHeight / 2 )
        , image pipeWidth pipeHeight "./src/pipe_up.png"
            |> toForm
            |> move ( pipe.x, gameHeight / 2 - pipe.height )
        ]


view : Game -> Html msg
view game =
    let
        ( w, h ) =
            game.windowDimensions

        bird =
            game.bird

        birdImage =
            image 35 35 "./src/flappy.png"

        groundY =
            10

        pipesForms =
            List.concatMap pipeToForms game.pipes

        backgroundForms =
            [ rect gameWidth gameHeight |> filled blueSky ]

        birdForm =
            [ birdImage |> toForm |> move ( bird.x, bird.y + groundY ) ]

        formList =
            List.append backgroundForms <|
                List.append birdForm <|
                    pipesForms
    in
        toHtml <|
            container w h middle <|
                collage gameWidth gameHeight formList


blueSky : Color
blueSky =
    rgb 174 238 238
