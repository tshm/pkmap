port module Pkmap exposing (main)

import Html exposing (input, label, img, a, nav, text, div, span, button)
import Geolocation
import Navigation
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
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
      (toString c.center.latitude) ++ "," ++ (toString c.center.longitude)
    hashStr =
      model.circles
        |> List.map toParamStr
        |> String.join "/"
  in "#" ++ hashStr

fromUrl : String -> Result String (List (Float, Float))
fromUrl url =
  let
    parseFloatPair str =
      case (String.split "," str) of
        a::b::[] -> Result.map2 (,) (String.toFloat a) (String.toFloat b)
        _ -> Err "parse error"
  in
    url
      |> String.dropLeft 1
      |> String.split "/"
      |> List.filter (not << String.isEmpty)
      |> List.map parseFloatPair
      |> allOk

allOk : List (Result String a) -> Result String (List a)
allOk arr =
  let
    pack result aggr =
      aggr `Result.andThen` \xs ->
        result `Result.andThen` \v ->
          Ok (v :: xs)
  in List.foldr pack (Ok []) arr

urlParser : Navigation.Parser (Result String (List (Float, Float)))
urlParser =
  Navigation.makeParser (fromUrl << .hash)

urlUpdate : Result String (List (Float,Float)) -> Model -> (Model, Cmd Msg)
urlUpdate result model =
  case result of
    Ok floatPairs ->
      let
        makeCircle (lat, lng) = Circle (Location lat lng) radius
        newcircles = List.map makeCircle floatPairs
      in ({ model | circles = newcircles }, drawCircles newcircles)
    Err msg ->
      let
        x = Debug.log "urlUpdate failure" msg
      in init result


-- MODEL

type alias Model =
  { location : Location
  , circles : List Circle
  }

type alias Location =
  { latitude : Float
  , longitude : Float
  }

type alias Circle =
  { center : Location
  , radius : Float
  }

radius : Float
radius = 200.0

init : Result String (List (Float,Float)) -> (Model, Cmd Msg)
init result =
  let
    emptymodel =
      { location = Location 0.0 0.0
      , circles = []
      }
    (model, cmd) = urlUpdate result emptymodel
  in model ! [ initMap True, cmd ]


-- UPDATE

type Msg
  = LocationChange Geolocation.Location
  | AddCircle
  | ResetCircle
  | RemoveCircle

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LocationChange geoloc ->
      let
        location = Location geoloc.latitude geoloc.longitude
      in ({ model | location = location }, locationChange location )

    AddCircle ->
      let
        circle = Circle model.location radius
        circles = circle :: model.circles
        newmodel = { model | circles = circles }
      in newmodel ! [ drawCircles circles, Navigation.modifyUrl (toUrl newmodel)]

    RemoveCircle ->
      case List.tail model.circles of
        Just circles ->
          let
            newmodel = { model | circles = circles }
          in newmodel ! [ drawCircles circles, Navigation.modifyUrl (toUrl newmodel)]
        Nothing -> (model, Cmd.none)

    ResetCircle ->
      let
        newmodel = { model | circles = []}
      in newmodel ! [ drawCircles [], Navigation.modifyUrl (toUrl newmodel)]

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
  let
    buttons =
      [ label [for "bmenub", class "burger pseudo button"] [ text "≡"]
      , button [ onClick RemoveCircle ]
        [ text "Delete"
        , Html.sup [] [ text <| toString (List.length model.circles )]
        ]
      , div [ class "menu"]
        [ label [ for "modal", class "error button"] [ text "Reset"]
        ]
      ]
  in
    Html.header []
      [ nav [] <|
        [ input [id "bmenub", type' "checkbox", class "show"] []
        , a [ href "#", class "brand"] [ text "PkMap" ]
        ] ++ if List.isEmpty model.circles then [] else buttons
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

