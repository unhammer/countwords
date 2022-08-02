module Main where

import Control.Monad      (foldM, when)
import Data.Char          (isSpace)
import Data.FastChar
import Data.List          (sortOn, filter)
import Data.Ord           (Down(..))
import System.IO          (stdin)
import System.Environment (getArgs)

-- text
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T

-- vector-hashtables
import qualified Data.Vector.Mutable as V
import qualified Data.Vector.Storable.Mutable as VM
import qualified Data.Vector.Unboxed.Mutable as UM
import qualified Data.Vector.Hashtables as H

type VHT = H.Dictionary (H.PrimState IO) V.MVector Text UM.MVector Int

main :: IO ()
main = do
  args <- getArgs
  let cutoff | length args > 0 = take (read $ head args) -- no error handling, to simplify the example
             | otherwise       = id
  freqtable <- H.initialize 64000 :: IO VHT
  T.hGetContents stdin >>= \contents -> do
    mapM_ (H.alter freqtable incf) $ filter (not . T.null) $ T.split isSpace $ T.map toLower contents
    counts <- H.toList freqtable
    traverse prettyPrint $ cutoff $ sortOn (Down . snd) counts
    pure ()

prettyPrint (a,b) = T.putStrLn $ a <> T.pack " " <> T.pack (show b)

incf Nothing  = Just 1
incf (Just x) = Just (x + 1)
{-# INLINE incf #-}
