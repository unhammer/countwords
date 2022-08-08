-- From https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864/13
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (unless)
import Data.Foldable
import Data.List (sortOn)
import Data.Ord (Down (..))
import qualified Data.Text as T
import qualified Data.Text.IO as T
import System.IO (isEOF)

import qualified TextCounter as C

import           Data.FastChar

unlessM :: Monad m => m Bool -> m () -> m ()
unlessM m1 m2 = m1 >>= \b -> unless b m2

main :: IO ()
main = do
  t <- C.new 48000 16000
  let go = unlessM isEOF $ do
        wrds <- T.words .  T.toLower <$> T.getLine
        traverse_ (C.count t) wrds
        go
  go
  xs <- sortOn (Down . snd) <$> C.toList t
  traverse_ (\(w, i) -> T.putStrLn (w `T.append` " " `T.append` T.pack (show i))) xs
