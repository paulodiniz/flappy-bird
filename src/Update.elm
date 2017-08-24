module Update exposing (..)

import Keyboard exposing (KeyCode)
import Time exposing (..)
import Model exposing (..)

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
