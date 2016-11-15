port module Pkmap exposing (main)

import Html exposing (input, label, img, a, nav, text, div, span, button)
import Geolocation
import Navigation
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Json.Decode
import String
import List

main : Program Flag Model Msg
main = Navigation.programWithFlags updateLocation
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- URL Handlers

-- | toUrl
-- >>> toUrl initModel
-- "#/"
--
toUrl : Model -> String
toUrl model =
  let
    toParamStr { center, radius } =
      [ center.latitude, center.longitude, radius ]
        |> List.map toString
        |> String.join ","
    hashStr =
      model.circles
        |> List.map toParamStr
        |> String.join "/"
  in "#/" ++ hashStr

-- | updateLocation
-- >>> updateLocation ""
-- LoadCircles []
--
-- >>> updateLocation "#/"
-- LoadCircles []
--
-- >>> updateLocation "#/1,2,3"
-- LoadCircles [Circle (Location 1 2) 3]
--
updateLocation : Navigation.Location -> Msg
updateLocation { hash } =
  let
    x = Debug.log "updateLocation" hash
    result =
        Json.Decode.decodeString (Json.Decode.list circle) jsonStr
    jsonStr =
      String.dropLeft 2 hash
        |> String.split "/"
        |> String.join "],["
        |> \x -> "[[" ++ x ++ "]]"
    circle =
      Json.Decode.map3
        (\x y z -> Circle (Location x y) z)
        ( Json.Decode.index 0 Json.Decode.float )
        ( Json.Decode.index 1 Json.Decode.float )
        ( Json.Decode.index 2 Json.Decode.float )
  in
    LoadCircles (Result.withDefault [] result)

-- MODEL

type alias Model =
  { location : Location
  , circles : List Circle
  , radius : Float
  , version : String
  }

type alias Location =
  { latitude : Float
  , longitude : Float
  }

type alias Circle =
  { center : Location
  , radius : Float
  }

type alias UrlArg =
  Maybe (List Circle)

type alias Flag =
  { version: String }

defaultRadius : Float
defaultRadius = 200.0

init : Flag -> Navigation.Location -> (Model, Cmd Msg)
init flag location =
  let
    model = { initModel | version = flag.version }
    (newmodel, cmd) = update (updateLocation location) model
  in newmodel ! [ cmd, initMap () ]

initModel : Model
initModel =
  { location = Location 0.0 0.0
  , circles = []
  , radius = defaultRadius
  , version = "unknown"
  }

-- UPDATE

type Msg
  = LocationChange Geolocation.Location
  | AddCircle
  | ResetCircle
  | RemoveCircle
  | LoadCircles (List Circle)
  --| ChangeRadius String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case Debug.log "msg" msg of
    LocationChange geoloc ->
      let
        location = Location geoloc.latitude geoloc.longitude
      in ({ model | location = location }, locationChange location )

    AddCircle ->
      let
        circle = Circle model.location model.radius
        circles = circle :: model.circles
      in update (LoadCircles circles) model

    RemoveCircle ->
      case List.tail model.circles of
        Just circles ->
          update (LoadCircles circles) model
        _ -> (model, Cmd.none)

    ResetCircle ->
      update (LoadCircles []) model

    LoadCircles circles ->
      if circles == model.circles
      then (model, Cmd.none)
      else
        let
          newmodel = {model | circles = circles}
        in newmodel
             ! [ drawCircles circles
               , Navigation.newUrl (toUrl newmodel)
               ]

    -- ChangeRadius str ->
    --   let
    --     radius = Result.withDefault defaultRadius <| String.toFloat str
    --   in { model | radius = radius } ! []

port initMap : () -> Cmd msg
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
    , Html.main_ []
      [ div [ id "map"] []
      , button [ onClick AddCircle, class "plus warning"] [ text "+"]
      ]
    ]

header : Model -> Html.Html Msg
header model =
  Html.header []
    [ nav []
      [ input [id "bmenub", type_ "checkbox", class "show"] []
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
        , label [] [ text model.version ]
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
    [ input [ id "modal", type_ "checkbox"] []
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

