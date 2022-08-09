{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}

-- | A module of finite data, and their compressed.
module Finite (
  Finite (..),
  Counter,
  new,
  count,
  Finite.toList,
) where

-- base
import Data.Bits
import Data.Foldable
import qualified Data.List as List
import Prelude hiding (lookup)

-- bytestring
import qualified Data.ByteString as B

-- primitive
import Control.Monad.Primitive (PrimMonad (PrimState))
import Data.Primitive
import qualified Data.Primitive.MutVar as MutVar

-- hashable
import Data.Hashable

-- | Convert a finite piece of data into a list of positive integers.
class Finite a where
  group :: a -> [Int]

instance Finite Int where
  group a =
    if
        | a <= 0 -> [0, negate a]
        | otherwise -> [a]
  {-# INLINE group #-}

instance Finite [Int] where
  group a = a
  {-# INLINE group #-}

instance Finite B.ByteString where
  group b = toWords b
   where
    toWords :: B.ByteString -> [Int]
    toWords !bs
      | B.null bs = []
      | otherwise =
        ( List.foldl'
            (\a r' -> a `unsafeShiftL` 7 .|. idx r')
            0
            [0 .. x - 1]
        ) :
        toWords (B.drop x bs)
     where
      x = min 9 t
      idx = fromIntegral . B.index bs
      t = B.length bs
  {-# INLINE group #-}

{- Fifth try is the charm.

  Idea:

  1. Encode all data as positive integers.
  2. Save entries in array of type:

    .|-C|W|W|W..|.
     |<--- n --->| = |Ws| + 1
-}

data Counter m a = MkCounter
  { _array :: !(MutableByteArray (PrimState m))
  , _entries :: !(MutVar.MutVar (PrimState m) [(a, Int)])
  }

new :: PrimMonad m => Int -> m (Counter m a)
new n = do
  t <- newByteArray (n * sizeOf (0 :: Int))
  setByteArray t 0 n (-1 :: Int)
  e <- MutVar.newMutVar []
  pure (MkCounter t e)
{-# INLINE new #-}

count :: (PrimMonad m, Finite a) => Counter m a -> a -> m ()
count = countOn group
{-# INLINE count #-}

countOn :: forall a m. (PrimMonad m) => (a -> [Int]) -> Counter m a -> a -> m ()
countOn group' (MkCounter t e) a = do
  go (h `mod` searchSpace)
 where
  ws = group' a
  wl = length ws
  h = hash ws
  searchSpace = size - wl - 2
  size = sizeofMutableByteArray t `quot` sizeOf (0 :: Int)

  go :: Int -> m ()
  go !i = do
    (c, j) <- findNegativeFrom i
    if
        | c < -1 -> do
          findFirstDiffFrom t (j + 1) ws >>= \case
            (-1) -> do
              x <- readByteArray @Int t (j + 1 + wl)
              if x < 0
                then writeByteArray t j (c - 1)
                else go (j + 1 + wl)
            k -> do
              go k
        | otherwise ->
          findFirstPositiveFromTo (j + 1) (j + 2 + wl) >>= \case
            (-1) -> do
              writeAllByteArray t j (-2 : ws)
              MutVar.modifyMutVar' e ((a, j) :)
            k -> do
              go k

  findNegativeFrom !i = do
    v <- readByteArray @Int t i
    if v < 0
      then return (v, i)
      else findNegativeFrom ((i + 1) `mod` searchSpace)

  findFirstPositiveFromTo i k = gof i
   where
    gof !j
      | j == k = return (-1)
      | otherwise = do
        v <- readByteArray @Int t j
        if
            | v < 0 -> gof (j + 1)
            | otherwise -> return j
{-# INLINE countOn #-}

toList :: PrimMonad m => Counter m a -> m [(a, Int)]
toList (MkCounter t e) = do
  mapM (\(a, i) -> (a,) . (-1 -) <$> readByteArray t i) =<< MutVar.readMutVar e
{-# INLINE toList #-}

writeAllByteArray ::
  PrimMonad m =>
  MutableByteArray (PrimState m) ->
  Int ->
  [Int] ->
  m ()
writeAllByteArray h = go
 where
  go !i = \case
    [] -> return ()
    x : xs -> do
      writeByteArray h i x
      writeAllByteArray h (i + 1) xs
{-# INLINE writeAllByteArray #-}

findFirstDiffFrom ::
  PrimMonad m =>
  MutableByteArray (PrimState m) ->
  Int ->
  [Int] ->
  m Int
findFirstDiffFrom h i = \case
  [] -> return (-1)
  x : xs -> do
    v <- readByteArray h i
    if
        | v == x -> go (i + 1) xs
        | otherwise -> return i
 where
  go !j = \case
    [] -> return (-1)
    x : xs -> do
      v <- readByteArray h j
      if
          | v == x -> go (j + 1) xs
          | otherwise -> return j
{-# INLINE findFirstDiffFrom #-}
