module CommitList.View (view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Date exposing (..)
import Date.Format exposing (..)
import Signal exposing (Address)

import CommitList.Model exposing(..)
import CommitList.Update exposing(..)

view address model =
  ul [ class "commits-list" ] (List.map (lazyRenderCommit address) model.commits)

lazyRenderCommit : Address Action -> Commit -> Html
lazyRenderCommit address commit =
  let
    render = (renderCommit address)
  in
    -- TODO: figure out if this actually works, the Debug.log is called
    --       for each commit even if only one has changed
    lazy render commit

renderCommit : Address Action -> Commit -> Html
renderCommit address commit =
  --let _ = Debug.log "commit" commit.id in
  li [ id (commitId commit), commitClassList(commit) ] [
    a [ class "block-link" ] [
      div [ class "commit-wrapper" ] [
        div [ class "commit-controls" ] [ (renderButton address commit) ]
      , img [ class "commit-avatar", src (avatarUrl commit) ] []
      , div [ class "commit-summary-and-details" ] [
          div [ class "commit-summary test-summary" ] [ text commit.summary ]
        , div [ class "commit-details" ] [
            text " in "
          , strong [] [ text commit.repository ]
          , span [ class "by-author" ] [
              text " by "
            , strong [] [ text commit.authorName ]
            , text " on "
            , span [ class "test-timestamp" ] [ text (formattedTime commit.timestamp) ]
            ]
          ]
        ]
      ]
    ]
  ]

renderButton : Address Action -> Commit -> Html
renderButton address commit =
  if commit.isBeingReviewed then -- todo should be isNew
    button [ class "small abandon-review test-button test-abandon-review", onClick address (AbandonReview commit.id) ] [
      i [ class "fa fa-eye-slash" ] [ text "Abandon review" ]
    ]
  else
    button [ class "small start-review test-button test-start-review", onClick address (StartReview commit.id) ] [
      i [ class "fa fa-eye" ] [ text "Start review" ]
    ]

commitClassList : Commit -> Attribute
commitClassList commit =
  classList [
    ("commit", True)
  , ("is-being-reviewed", commit.isBeingReviewed)
  , ("is-reviewed", commit.isReviewed)
  , ("test-is-reviewed", commit.isReviewed)
  , ("test-commit", True)
  ]

formattedTime : String -> String
formattedTime timestamp =
  timestamp
  |> Date.fromString
  |> Result.withDefault (Date.fromTime 0)
  |> Date.Format.format "%a %e %b at %H:%M" -- E.g. Wed 3 Feb at 15:14

avatarUrl : Commit -> String
avatarUrl commit =
 "https://secure.gravatar.com/avatar/" ++ commit.gravatarHash ++ "?size=40&amp;rating=x&amp;default=mm"

commitId : Commit -> String
commitId commit =
  "commit-" ++ toString commit.id