module Update exposing (..)

-- import Keyboard exposing (KeyCode)
-- import Time exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Phoenix.Socket
import Phoenix.Push
import Random
import Debug
import Json.Decode as JD
import Json.Encode as JE

update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case game.state of
        Play ->
            case msg of
                UpdateTopPlayers raw ->
                    let
                        someMessage = JD.field "message" JD.string
                        _ = Debug.log "Message is "someMessage
                    in
                        (game, Cmd.none)

                TimeUpdate dt ->
                    ( updateFlappy game, Cmd.none )

                KeyDown keyCode ->
                    ( { game | bird = jump game.bird }, Cmd.none )

                GeneratePipe _ ->
                    ( game, Random.generate NewPipe (Random.float 50 400) )

                NewPipe height ->
                    ( generateNewPipe game height, Cmd.none )

                JoinGame ->
                    let
                        phxPush =
                            Phoenix.Push.init "join_game" "game:lobby"
                                |> Phoenix.Push.withPayload (JE.object [])
                        (phxSocket, phxCmd) = Phoenix.Socket.push phxPush game.phxSocket
                    in
                        ({game | phxSocket = phxSocket}, Cmd.map PhoenixMsg phxCmd)

                PhoenixMsg msg ->
                    let
                        ( phxSocket, phxCmd ) = Phoenix.Socket.update msg game.phxSocket
                    in
                        ( { game | phxSocket = phxSocket }
                        , Cmd.map PhoenixMsg phxCmd
                        )
                JoinedGame raw ->
                    let
                        decodedValue = decodeJoiningGame raw
                        _ = Debug.log "Decoded Value " decodedValue
                    in
                        case decodedValue of
                            Ok (name, uid) ->
                                ({game | name = Just name, uid = Just uid}, Cmd.none)
                            Err error ->
                                (game, Cmd.none)
        Start ->
            case msg of
                KeyDown keyCode ->
                    { game | state = Play} |> update JoinGame
                _ ->
                    ( game, Cmd.none )

        GameOver ->
            ( game, Cmd.none )


decodeJoiningGame : JD.Value -> Result String ( String, String )
decodeJoiningGame raw =
    JD.decodeValue joiningDecoder raw

joiningDecoder : JD.Decoder (String, String)
joiningDecoder =
    JD.map2 (,)
          (JD.field "name" JD.string)
          (JD.field "uid" JD.string)

generateNewPipe : Game -> Float -> Game
generateNewPipe game height =
    let
        bottomHeight =
            height

        upHeight =
            400 - bottomHeight + 200

        upPipe =
            { height = upHeight
            , width = 75
            , x = 300
            , y = gameHeight / 2
            , direction = Up
            , passed = False
            }

        downPipe =
            { height = bottomHeight
            , width = 75
            , x = 300
            , y = -gameHeight / 2
            , direction = Down
            , passed = False
            }
    in
        { game | pipes = List.append game.pipes [ upPipe, downPipe ] }


updateFlappy : Game -> Game
updateFlappy game =
    game
        |> gravity
        |> physics
        |> upperLimit
        |> checkPipeColision
        |> updatePipes
        |> updateScore


updateScore : Game -> Game
updateScore game =
    let
        score =
            List.filter (\pipe -> pipe.passed == True) game.pipes
                |> List.length
                |> (\x -> x // 2)
    in
        { game | score = score }


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
            if bird.y <= (gameHeight / 2) then
                { bird | y = bird.y + bird.vy }
            else
                { bird | y = (gameHeight / 2) }
    in
        { game | bird = newBird }


gravityValue : Float
gravityValue =
    0.45


jump : Bird -> Bird
jump bird =
    { bird | vy = 6 }


updatePipes : Game -> Game
updatePipes game =
    let
        bird =
            game.bird
    in
        { game | pipes = List.map (\pipe -> updatePipe bird pipe) game.pipes }


updatePipe : Bird -> Pipe -> Pipe
updatePipe bird pipe =
    let
        birdWidth =
            35

        leftBird =
            bird.x - birdWidth / 2 + 10

        passed =
            if (leftBird >= (pipe.x + pipe.width)) then
                True
            else
                False
    in
        { pipe | x = pipe.x - bird.vx, passed = passed }


upperLimit : Game -> Game
upperLimit game =
    let
        bird =
            game.bird
    in
        if bird.y <= -(gameHeight / 2) then
            { game | state = GameOver }
        else
            game


checkPipeColision : Game -> Game
checkPipeColision game =
    let
        bird =
            game.bird

        pipesToCheck =
            List.filter (\pipe -> pipe.x >= bird.x) game.pipes

        pipesColiding =
            List.any (\pipe -> isColiding bird pipe) pipesToCheck
    in
        if pipesColiding then
            { game | state = GameOver }
        else
            game


isColiding : Bird -> Pipe -> Bool
isColiding bird pipe =
    let
        birdWidth =
            35

        birdHeight =
            35

        rightBird =
            bird.x + birdWidth / 2 - 10

        leftBird =
            bird.x - birdWidth / 2 + 10

        upBird =
            bird.y + birdHeight / 2

        downBird =
            bird.y - birdHeight / 2 + 17

        leftPipe =
            pipe.x - pipe.width / 2

        rightPipe =
            pipe.x + pipe.width / 2

        upPipe =
            pipe.y + pipe.height / 2

        downPipe =
            pipe.y - pipe.height / 2
    in
        not <|
            (leftPipe > rightBird)
                || (rightPipe < leftBird)
                || (upPipe < downBird)
                || (downPipe > upBird)
