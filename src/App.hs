{-# LANGUAGE LambdaCase #-}
module App
  ( api
  , app
  ) where

import Data.Acid
import Data.ByteString.Char8 (unpack)
import Data.Text.Encoding (encodeUtf8)
import Control.Monad.IO.Class
import Crypto.Hash
import Servant
import qualified Data.Text as Text
import qualified Data.Map as Map

import API
import Store

server :: Server API
server = (save :<|> load) :<|> serveDirectoryFileServer "static"
  where
    save :: Snippet -> Handler SnippetId
    save (Snippet s) = do
        let bytes = encodeUtf8 s
        let hex = digestToHexByteString (hash bytes :: Digest MD5)
        let sid = SnippetId . unpack $ hex
        liftIO $ do
            state <- openLocalState (SnippetDb Map.empty)
            update state (AddSnippet sid $ Snippet s)
            closeAcidState state
            return sid

    load :: String -> Handler Snippet
    load sid = do
        liftIO $ do
            state <- openLocalState (SnippetDb Map.empty)
            snip <- query state (GetSnippet $ SnippetId sid) >>= \case
                Nothing -> return $ Snippet Text.empty
                Just s -> return $ s
            closeAcidState state
            return snip

api :: Proxy API
api = Proxy

app :: Application
app = serve api server
