port module Pkmap exposing (main)

import Html exposing (input, label, img, a, nav, text, div, span, button)
import Geolocation
import Navigation
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Json.Decode
import String
import List

main : Program Never
main = Navigation.program urlParser
  { init = init
  , view = view
  , update = update
  , urlUpdate = urlUpdate
  , subscriptions = subscriptions
  }


-- URL Handlers

toUrl : Model -> String
toUrl model =
  let
    toParamStr c =
      (toString c.center.latitude) ++ "," ++
      (toString c.center.longitude) ++ "," ++
      (toString c.radius)
    hashStr =
      model.circles
        |> List.map toParamStr
        |> String.join "/"
  in "#" ++ hashStr

fromUrl : String -> Result String (List Circle)
fromUrl url =
  let
    circleDecoder =
      Json.Decode.tuple3
        (\x y z -> Circle (Location x y) z)
        Json.Decode.float
        Json.Decode.float
        Json.Decode.float
    parseFloatTriple str =
      Json.Decode.decodeString
        (Json.Decode.list circleDecoder) str
  in
    url
      |> String.dropLeft 1
      |> String.split "/"
      |> List.filter (not << String.isEmpty)
      |> String.join "],["
      |> \str -> "[[" ++ str ++ "]]"
      |> parseFloatTriple

urlParser : Navigation.Parser (Result String (List Circle))
urlParser =
  Navigation.makeParser (fromUrl << .hash)

urlUpdate : Result String (List Circle) -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  case result of
    Ok circles ->
      ({ model | circles = circles }, drawCircles circles)
    Err msg ->
      (model, Cmd.none)


-- MODEL

type alias Model =
  { location : Location
  , circles : List Circle
  , radius : Float
  }

type alias Location =
  { latitude : Float
  , longitude : Float
  }

type alias Circle =
  { center : Location
  , radius : Float
  }

defaultRadius : Float
defaultRadius = 200.0

init : Result String (List Circle) -> (Model, Cmd Msg)
init result =
  let
    initModel =
      { location = Location 0.0 0.0
      , circles = []
      , radius = defaultRadius
      }
    (model, cmd) = urlUpdate result initModel
  in model ! [ initMap True, cmd ]


-- UPDATE

type Msg
  = LocationChange Geolocation.Location
  | AddCircle
  | ResetCircle
  | RemoveCircle
  --| ChangeRadius String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LocationChange geoloc ->
      let
        location = Location geoloc.latitude geoloc.longitude
      in ({ model | location = location }, locationChange location )

    AddCircle ->
      let
        circle = Circle model.location model.radius
        circles = circle :: model.circles
        newmodel = { model | circles = circles }
      in newmodel ! [ Navigation.modifyUrl (toUrl newmodel)]

    RemoveCircle ->
      case List.tail model.circles of
        Just circles ->
          let
            newmodel = { model | circles = circles }
          in newmodel ! [ Navigation.modifyUrl (toUrl newmodel)]
        Nothing -> model ! []

    ResetCircle ->
      let
        newmodel = { model | circles = []}
      in newmodel ! [ Navigation.modifyUrl (toUrl newmodel)]

    -- ChangeRadius str ->
    --   let
    --     radius = Result.withDefault defaultRadius <| String.toFloat str
    --   in { model | radius = radius } ! []

port initMap : Bool -> Cmd msg
port locationChange : Location -> Cmd msg
port drawCircles : List Circle -> Cmd msg


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Geolocation.changes LocationChange 


-- VIEW

view : Model -> Html.Html Msg
view model =
  div []
    [ header model
    , modal
    , Html.main' []
      [ div [ id "map"] []
      , button [ onClick AddCircle, class "plus warning"] [ text "+"]
      ]
    ]

header : Model -> Html.Html Msg
header model =
  Html.header []
    [ nav []
      [ input [id "bmenub", type' "checkbox", class "show"] []
      , a [ href "#", class "brand"] [ text "PkMap" ]
      , label [for "bmenub", class "burger pseudo button"] [ text "≡"]
      , button [ onClick RemoveCircle, disabled (List.isEmpty model.circles )]
        [ text "Delete"
        , Html.sup [] [ text <| toString (List.length model.circles )]
        ]
      , div [ class "menu"]
        [ label
          [ for "modal"
          , class "error button"
          , disabled (List.isEmpty model.circles )
          ]
          [ text "Reset"]
        -- , label []
        --   [ text "radius:"
        --   , input
        --       [ value ( toString model.radius )
        --       , onInput ChangeRadius
        --       ]
        --       []
        --   ]
        ]
      ]
    ]

modal : Html.Html Msg
modal =
  Html.div [ class "modal"]
    [ input [ id "modal", type' "checkbox"] []
    , label [ for "modal", class "overlay"] []
    , Html.article []
      [ Html.header []
        [ text "Confirm"
        , label [ for "modal", class "close"] [ text "×"]
        ]
      , Html.section [] [ text "Are you sure to remove all marks?"]
      , Html.footer []
        [ label [ for "modal"]
          [ a [ class "button dangerous", onClick ResetCircle ] [text "OK"]
          ]
        ]
      ]
    ]

