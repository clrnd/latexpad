{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module Lib
    ( startApp
    ) where

import Data.Aeson
import Data.Aeson.TH
import Data.Text
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Servant

import Debug.Trace

data Snippet = Snippet
  { snippetContent :: Text
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''Snippet)

data SnippetId = SnippetId
  { snippetId :: Int
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''SnippetId)

type API = "store" :> ReqBody '[JSON] Snippet :> Post '[JSON] SnippetId

server :: Server API
server = snippet
  where
    snippet :: Snippet -> Handler SnippetId
    snippet s = traceShow s $ return (SnippetId 1)

api :: Proxy API
api = Proxy

app :: Application
app = serve api server

startApp :: IO ()
startApp = run 8080 (logStdoutDev app)
