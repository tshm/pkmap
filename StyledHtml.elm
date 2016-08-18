module StyledHtml exposing (icon, spinner, button, div)
{-| Html elements added with custom style
-}

import Html
import Html.Attributes exposing (..)
import String exposing (concat)

icon : List String -> Html.Html msg
icon name =
  Html.i [ class "material-icons" ] [ Html.text <| String.concat name ]
-- icon xs =
--   let cls = List.foldr (\x s -> s ++ (" fa-" ++ x)) "fa" xs
--   in Html.i [ class cls ] []

div : List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
div = Html.div

button : String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
button cls attr html =
  let
    baseclass = "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect "
  in
    Html.a ((Html.Attributes.class (baseclass ++ cls)) :: attr) html

spinner : Html.Html msg
spinner =
  Html.div
  [ class "mdl-spinner mdl-js-spinner is-active" ]
  []
