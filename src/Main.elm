module Main exposing (..)

import AnimationFrame
import Collage exposing (..)
import Color exposing (..)
import Element exposing (..)
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (..)
import Array


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
    , pipes : Array.Array Pipe
    , windowDimensions : ( Int, Int )
    }


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type alias Pipe =
    { x : Float
    , y : Float
    , height : Float
    , passed : Bool
    }


initialBird : Bird
initialBird =
    { x = 30
    , y = 100
    , vx = 0
    , vy = 0
    }


( gameWidth, gameHeight ) =
    ( 600, 400 )


initialGame : Game
initialGame =
    { bird = initialBird
    , pipes = Array.empty
    , windowDimensions = ( gameWidth, gameHeight )
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
    case msg of
        TimeUpdate dt ->
            ( updateFlappy game, Cmd.none )

        KeyDown keyCode ->
            ( { game | bird = jump game.bird }, Cmd.none )

        GeneratePipe _ ->
            ( generateNewPipe game, Cmd.none )


generateNewPipe : Game -> Game
generateNewPipe game =
    let
        newPipe =
          { x = 300
          , y = 100
          , height = 3
          , passed = False
          }
    in
      { game | pipes = Array.append game.pipes <| Array.fromList [newPipe] }


updateFlappy : Game -> Game
updateFlappy game =
    game
        |> gravity
        |> physics
        |> updatePipes


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
            { bird | y = bird.y + bird.vy }
    in
        { game | bird = newBird }


gravityValue : Float
gravityValue =
    0.45


jump : Bird -> Bird
jump bird =
    { bird | vy = 8 }


twoSeconds : Time
twoSeconds =
    Time.second * 2


updatePipes : Game -> Game
updatePipes game =
    let
        updatedPipes = Array.map updatePipe game.pipes
    in
        { game | pipes = updatedPipes }

updatePipe : Pipe -> Pipe
updatePipe pipe =
    { pipe | x = pipe.x - 10 }

-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every twoSeconds GeneratePipe
        ]


pipeToForm : Pipe -> Form
pipeToForm pipe =
    let
        pipeWidth =
            75

        pipeHeight =
            100
    in
        image pipeWidth pipeHeight "pipe.png"
            |> toForm
            |> move ( pipe.x, pipe.y - 250)


view : Game -> Html msg
view game =
    let
        ( w, h ) =
            game.windowDimensions

        bird =
            game.bird

        birdImage =
            image 35 35 "flappy.png"

        groundY =
            10

        pipesForm =
            Array.map pipeToForm game.pipes |> Array.toList

        backgroundForms =
            [ rect gameWidth gameHeight |> filled blueSky ]

        birdForm =
            [ birdImage |> toForm |> move ( bird.x, bird.y + groundY ) ]

        pipeForms =
            Array.map pipeToForm game.pipes |> Array.toList

        formList =
            List.append backgroundForms <|
                List.append birdForm <|
                    pipeForms
    in
        toHtml <|
            container w h middle <|
                collage gameWidth gameHeight formList


blueSky : Color
blueSky =
    rgb 174 238 238
