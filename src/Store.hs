{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Store
  ( Snippet(Snippet)
  , SnippetId(SnippetId)
  , SnippetDb(SnippetDb)
  , GetSnippet(GetSnippet)
  , AddSnippet(AddSnippet)
  ) where

import Control.Monad.Reader (ask)
import Control.Monad.State (modify)
import Data.Aeson
import Data.Aeson.TH
import Data.Acid
import Data.Map (Map)
import Data.SafeCopy
import Data.Typeable
import Data.Text (Text)
import qualified Data.Map as Map

newtype SnippetId = SnippetId
  { snippetId :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''SnippetId)

newtype Snippet = Snippet
  { snippetContent :: Text
  } deriving (Eq, Show, Typeable)

$(deriveJSON defaultOptions ''Snippet)

newtype SnippetDb = SnippetDb
    { allSnippets :: Map String Snippet
    } deriving (Typeable)


addSnippet :: SnippetId -> Snippet -> Update SnippetDb ()
addSnippet (SnippetId id') snippet = modify go
  where
    go (SnippetDb db) = SnippetDb $
        Map.insert id' snippet db

getSnippet :: SnippetId -> Query SnippetDb (Maybe Snippet)
getSnippet (SnippetId id') =
    Map.lookup id' . allSnippets <$> ask

deriveSafeCopy 0 'base ''Snippet
deriveSafeCopy 0 'base ''SnippetId
deriveSafeCopy 0 'base ''SnippetDb
makeAcidic ''SnippetDb ['getSnippet, 'addSnippet]
