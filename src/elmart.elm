import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import Random
import List
import Html.Events exposing (onInput)
import Html exposing (Html, Attribute, div, input)
import Html.Attributes exposing (..)


type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | ChangePos            -- Decreases Position for Shape
         | RotatePos            -- Change Direction of Rotation
         | GenColor Color       -- Generates a random color
         | ArtScreen            -- Go to Art Screen
         | ChangeA String       -- Update Angle Increment Parameter
         | ChangeL String       -- Update Position Increment Parameter
         
--Model                      -- Shape Properties
type alias Model = { pos : Pos , angle : Float , color : Color, shapeL: List (Shape Msg), dir : Float
                             -- Main Page Parameters
                            , artScreen: Bool, speed: String, loc: String} 

-- Position for Shape
type alias Pos = { x : Float , y : Float }


init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url keys = ( { pos = { x = 0.0, y = 0.0 } , angle = 1.0 , color = white, shapeL = [], dir = 1, artScreen = False, speed = "4", loc = "1"} , Cmd.none) 

-- Generates a random Color
colorX : Random.Generator Color
colorX = Random.map3 (\r g b -> rgb r g b) (Random.float 100 255) (Random.float 100 255) (Random.float 100 255)


-- Function for the shapes used in the animation
addShapes : Model -> Shape Msg 
addShapes model =  union ((circle 80) 
                           |> outlined (solid 1) model.color )
                         ((circle 40) 
                           |> outlined (solid 1) model.color )
                 
                   |> move (model.pos.x, model.pos.y)
                   |> rotate (model.angle * model.dir)
                   |> notifyTap ChangePos 
                   |> notifyTap RotatePos 

-- Function for converting string from text field to float
stringToFloat: String -> Float
stringToFloat n = case String.toFloat(n) of 
                        Just x -> x
                        Nothing -> 4   

-- Update Function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of                   -- Increments of angle and position happen when on artScreen
                     Tick time keystate    -> ({ model | angle = (if (model.angle > 0 && model.artScreen) then model.angle + stringToFloat(model.speed)  
                                                                        else if (model.angle > 0 && model.artScreen) then model.angle - stringToFloat(model.speed)
                                                                        else model.angle)
                                               , pos = { x = (if model.pos.x > 300 && model.artScreen then model.pos.x - stringToFloat(model.loc) 
                                                                        else if (model.pos.x < 300 && model.artScreen) then model.pos.x + stringToFloat(model.loc)
                                                                        else model.pos.x)
                                               , y = (if model.pos.y > 300 && model.artScreen then model.pos.y - stringToFloat(model.loc) 
                                                                        else if (model.pos.y < 300 && model.artScreen) then model.pos.y + stringToFloat(model.loc)
                                                                        else model.pos.y )}
                                                -- Add the circles with specific position made from increments
                                               , shapeL = if model.artScreen then model.shapeL ++ [addShapes model] else [] }
                                                -- Generates random colors each time
                                               , Random.generate GenColor colorX)

                     MakeRequest req       -> (model,Cmd.none)

                     UrlChange url         -> (model,Cmd.none)

                     ArtScreen             -> ({ model | artScreen = True}, Cmd.none)

                     ChangeA n             -> ({ model | speed = n }, Cmd.none)

                     ChangeL n             -> ({ model | loc = n }, Cmd.none)

                     GenColor randomColor  -> ({ model | color = randomColor }, Cmd.none )
                                               -- Changes the position of shape
                     ChangePos             -> ({ model | pos = { x = model.pos.x - 200, y = model.pos.y - 200 } }, Cmd.none)
                                               -- Changes the direction of rotation
                     RotatePos             -> ({ model | dir = if model.dir == 1.0 then -1.0 else 1.0 }, Cmd.none)

-- View
view : Model -> { title : String, body : Collage Msg }
view model = 
    let 
        title =
             "Interactive Animations"
        -- Screen for Animation
        artPage = ([rect 1000 500
                              |> filled black
                              |> notifyTap ChangePos 
                              |> notifyTap RotatePos                             
                             ] ++ model.shapeL)
        
        mainScreen = [union (roundedRect 100 25 3
                             |> filled blue
                             |> notifyTap ArtScreen 
                             |> move(0,20)   
                           )
                           (text "Start Animation"
                             |> GraphicSVG.size 14
                             |> filled white
                             |> move (-45,16)
                             |> notifyTap ArtScreen
                           )]
        -- Main Menu Text
        mainScreenMsg = [ text "Create your own Animation!"
                            |> GraphicSVG.size 24
                            |> filled blue 
                            |> move (-125, 70)
                        ]
        -- Text for Angle
        sFieldMsg =     [ text "Increment for Angle"
                            |> GraphicSVG.size 14
                            |> filled blue
                            |> move (-150, -35)
                        ]
        -- Text for Position
        pFieldMsg =     [ text "Increment for Position"
                            |> GraphicSVG.size 14
                            |> filled blue
                            |> move (40, -35)
                        ]
        -- Text field for Angle
        angleField = html 200 200 (div [] [input [ placeholder "", value model.speed, onInput ChangeA ] [] ]) 
                                    |> move(-160,-40)
        -- Text field for Position
        locField = html 200 200 (div [] [input [ placeholder "", value model.loc, onInput ChangeL ] [] ])
                                    |> move (38,-40)

        body = 
            collage 1000 500 
                            (if model.artScreen then
                               artPage
                             else
                               mainScreen ++ mainScreenMsg ++ sFieldMsg  ++ pFieldMsg ++ [angleField, locField]
                               
                            )
                            
                            
    in { title = title , body = body }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : AppWithTick () Model Msg
main = appWithTick Tick
       { init = init
       , update = update
       , view = view
       , subscriptions = subscriptions
       , onUrlRequest = MakeRequest
       , onUrlChange = UrlChange
       }