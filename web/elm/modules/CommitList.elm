module CommitList where

import Html exposing (..)
import String

import CommitList.Update exposing(..)
import CommitList.Model exposing(..)
import CommitList.View exposing(view)

main : Signal Html
main =
  Signal.map (view inbox.address) model

---- API to the outside world (javascript/server) ----

--- receives commits to display at the start
port initialCommits : List Commit

-- receives updated commit data
port updatedCommit : Signal Commit

-- publishes events like [ "StartReview", "12" ]
port outgoingCommands : Signal (List String)
port outgoingCommands =
  Signal.map (\action ->
    action |> toString |> String.split(" ")
  ) inbox.signal


---- All possible ways state can change ----

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    StartReview id ->
      updateCommitById (\commit -> { commit | isBeingReviewed = True }) id model

    AbandonReview id ->
      updateCommitById (\commit -> { commit | isBeingReviewed = False }) id model

    -- triggers when someone else updates a commit and we receive a websocket push with an update for a commit
    UpdatedCommit commit ->
      updateCommitById (\_ -> commit) commit.id model

updateCommitById : (Commit -> Commit) -> Int -> Model -> Model
updateCommitById callback id model =
  let
    updateCommit commit =
      if commit.id == id then
        (callback commit)
      else
        commit
  in
     { model | commits = (List.map updateCommit model.commits)}


---- current state and action collection ----

model =
  let initialModel = { commits = initialCommits }
  in Signal.foldp update initialModel actions

actions : Signal Action
actions =
  Signal.merge inbox.signal updatedCommitActions

updatedCommitActions : Signal Action
updatedCommitActions =
  Signal.map (\commit -> (UpdatedCommit commit)) updatedCommit
