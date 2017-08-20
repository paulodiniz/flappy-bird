module Main exposing (..)

import AnimationFrame
import Collage exposing (..)
import Color exposing (..)
import Element exposing (..)
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (Time)


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


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


initialBird : Bird
initialBird =
    { x = 30
    , y = 100
    , vx = 0
    , vy = -0.8
    }


( gameWidth, gameHeight ) =
    ( 600, 400 )


type alias Game =
    { windowDimensions : ( Int, Int )
    , bird : Bird
    }


initialGame : Game
initialGame =
    { windowDimensions = ( gameWidth, gameHeight )
    , bird = initialBird
    }


init : ( Game, Cmd Msg )
init =
    ( initialGame, Cmd.none )



-- UPDATE


type Msg
    = TimeUpdate Time
    | KeyDown KeyCode


update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case msg of
        TimeUpdate dt ->
            ( { game | bird = updateFlappy game.bird }, Cmd.none )

        KeyDown keyCode ->
            ( { game | bird = jump game.bird }, Cmd.none )


updateFlappy : Bird -> Bird
updateFlappy bird =
    bird
        |> gravity
        |> physics


gravity : Bird -> Bird
gravity bird =
    { bird
        | vy =
            if bird.y > -(gameHeight / 2) then
                bird.vy - gravityValue
            else
                0
    }

gravityValue : Float
gravityValue =
    0.45

physics : Bird -> Bird
physics bird =
    { bird
        | y = bird.y + bird.vy
    }


jump : Bird -> Bird
jump bird =
    { bird
        | vy = 8
    }



-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        ]


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
    in
        toHtml <|
            container w h middle <|
                collage gameWidth
                    gameHeight
                    [ rect gameWidth gameHeight |> filled blueSky
                    , birdImage
                        |> toForm
                        |> move ( bird.x, bird.y + groundY )
                    ]


blueSky : Color
blueSky =
    rgb 174 238 238
