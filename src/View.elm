module View exposing (view)

import Html exposing (Html)


-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

import Element exposing (..)
import Collage exposing (..)
import Color exposing (..)
import Model exposing (..)
import Text


view : Game -> Html msg
view game =
    let
        ( w, h ) =
            game.windowDimensions

        bird =
            game.bird

        birdImage =
            image 35 35 "img/flappy.png"

        groundY =
            10

        pipesForms =
            List.concatMap pipeToForms game.pipes

        backgroundForms =
            [ rect gameWidth gameHeight |> filled blueSky ]

        birdForm =
            [ birdImage |> toForm |> move ( bird.x, bird.y + groundY ) ]

        scoreForm =
            Text.fromString (toString game.score)
                |> (Text.height 50)
                |> Text.color (Color.rgb 50 160 50)
                |> Text.bold
                |> text
                |> move ( 0, gameHeight / 2 - 50 )

        textForms =
            [ scoreForm ]

        formList =
            List.append backgroundForms <|
                List.append birdForm <|
                    List.append pipesForms <|
                        textForms
    in
        Html.div []
            [ toHtml <|
                container w h middle <|
                    collage gameWidth gameHeight formList
            , playersList game.name game.topPlayers
            ]


playersList : Maybe String -> List TopPlayer -> Html msg
playersList name players =
    -- let
        -- _ = Debug.log "LISTA DE PLAYERS" players
    -- in
        Html.ul [] (List.map (\p -> Html.li [] [ displayPlayer name p]) players)


displayPlayer : Maybe String -> TopPlayer -> Html msg
displayPlayer gameName player =

    let
        message = case gameName of
                Nothing ->
                    ""
                Just val ->
                    if val == player.name then
                        "!! That's you!"
                    else
                        ""
    in
        Html.text(player.name ++ " - " ++ toString(player.score) ++ message)

blueSky : Color
blueSky =
    rgb 174 238 238


pipeToForms : Pipe -> List Form
pipeToForms pipe =
    let
        pipeWidth =
            round pipe.width

        pipeHeight =
            round pipe.height

        img =
            case pipe.direction of
                Up ->
                    "img/pipe_up.png"

                Down ->
                    "img/pipe_down.png"
    in
        [ image pipeWidth pipeHeight img
            |> toForm
            |> move ( pipe.x, pipe.y )
        ]
