-- From https://discourse.haskell.org/t/mutable-data-structures-why-so-hard-to-find/4558/54
{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Data.Foldable
import           Data.List       (sortBy)
import           Data.Ord        (Down (..), comparing)
import qualified Data.Text       as T
import qualified Data.Text.IO    as T

import qualified Data.Vector.Mutable as VM
import qualified Data.Vector.Unboxed.Mutable as UM
import qualified Data.Vector.Hashtables as H

import Control.Monad
import Control.Monad.Primitive
import System.IO

type HashTable k v = H.Dictionary (PrimState IO) VM.MVector k UM.MVector v

unlessM :: Monad m => m Bool -> m () -> m ()
unlessM m1 m2 = m1 >>= \b -> unless b m2

main :: IO ()
main = do
  t <- H.initialize 10000 :: IO (HashTable T.Text Int)
  let
    go = unlessM isEOF $ do
      words <- T.words . T.toLower <$> T.getLine
      traverse_ (H.alter t (Just . maybe 1 (+ 1))) words
      go
  go
  xs <- sortBy (comparing (Down . snd)) <$> H.toList t
  traverse_ (\(w, i) -> T.putStrLn (w `T.append` " " `T.append` T.pack (show i))) xs
