{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module API
  ( API
  ) where

import Servant

import Store

type SnippetAPI =
         "save" :> ReqBody '[JSON] Snippet :> Post '[JSON] SnippetId
    :<|> "load" :> Capture "id" String :> Get '[JSON] Snippet

type API =
         "api" :> SnippetAPI
    :<|> Raw
