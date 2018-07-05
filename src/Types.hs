{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
module Types
  ( Snippet(Snippet)
  , SnippetId(SnippetId)
  , SnippetDb(SnippetDb, allSnippets)
  ) where

import GHC.Generics
import Data.Aeson
import Data.Typeable
import Data.Text (Text)
import Data.Map (Map)


newtype SnippetId = SnippetId
  { snippetId :: String
  } deriving (Eq, Show, Generic)

instance ToJSON SnippetId

newtype Snippet = Snippet
  { snippetContent :: Text
  } deriving (Eq, Show, Typeable, Generic)

instance ToJSON Snippet
instance FromJSON Snippet

newtype SnippetDb = SnippetDb
    { allSnippets :: Map String Snippet
    } deriving (Typeable)
