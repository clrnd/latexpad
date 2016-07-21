{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
module Lib
    ( startApp
    ) where

import Data.Acid
import Data.ByteString.Char8 (unpack)
import Data.Text.Encoding (encodeUtf8)
import Control.Monad.IO.Class
import Crypto.Hash
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Servant
import qualified Data.Text as Text
import qualified Data.Map as Map


import Store
import Debug.Trace

type API = "store" :> ReqBody '[JSON] Snippet :> Post '[JSON] SnippetId
      :<|> "get" :> Capture "id" String :> Get '[JSON] Snippet

server :: Server API
server = snippet :<|> get
  where
    snippet :: Snippet -> Handler SnippetId
    snippet (Snippet s) = do
        let bytes = encodeUtf8 s
        let hex = digestToHexByteString (hash bytes :: Digest MD5)
        let sid = SnippetId . unpack $ hex
        sid <- liftIO $ do
            state <- openLocalState (SnippetDb Map.empty)
            update state (AddSnippet sid $ Snippet s)
            closeAcidState state
            return sid
        return sid

    get :: String -> Handler Snippet
    get ss = do
        liftIO $ do
            state <- openLocalState (SnippetDb Map.empty)
            snip <- query state (GetSnippet $ SnippetId ss) >>= \case
                Nothing -> return $ Snippet Text.empty
                Just s -> return $ s
            closeAcidState state
            return snip

api :: Proxy API
api = Proxy

app :: Application
app = serve api server

startApp :: IO ()
startApp = run 8080 (logStdoutDev app)
