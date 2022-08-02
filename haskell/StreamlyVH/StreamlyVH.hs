-- Based on
-- https://github.com/composewell/streamly-examples/blob/master/examples/WordFrequency.hs
-- but I don't seem to have classifyMutWith so explicitly making a HashMap of IORefs

import Data.Foldable (traverse_)
import Data.Function ((&))
import System.Environment (getArgs)
import System.IO          (stdin)

import Data.FastChar
import Data.Char          (isSpace)
import qualified Data.List as List
import qualified Data.Ord as Ord
import Data.List          (sortOn, filter)
import Data.Ord           (Down(..))

-- streamly
import qualified Streamly.Data.Fold as Fold
import qualified Streamly.Internal.FileSystem.File as File (toBytes)
import qualified Streamly.Internal.FileSystem.Handle as Handle
import qualified Streamly.Prelude as Stream
import qualified Streamly.Unicode.Stream as Unicode

-- vector-hashtables
import qualified Data.Vector.Mutable as V
import qualified Data.Vector.Storable.Mutable as VM
import qualified Data.Vector.Unboxed.Mutable as UM
import qualified Data.Vector.Hashtables as H

type VHT = H.Dictionary (H.PrimState IO) V.MVector String UM.MVector Int

main :: IO ()
main = do
    args <- getArgs
    let cutoff | length args > 0 = take (read $ head args) -- no error handling, to simplify the example
               | otherwise       = id

    freqtable <- H.initialize 64000 :: IO VHT
    mp <-
        Stream.unfold Handle.read stdin
         & Unicode.decodeUtf8                   -- SerialT IO Char
         & Stream.map toLower                   -- SerialT IO Char
         & Stream.wordsBy isSpace Fold.toList   -- SerialT IO String
         & Stream.filter (all isAlpha)          -- SerialT IO String
         & Stream.mapM_ (H.alter freqtable incf) -- IO (Map String (IORef Int))

    -- Print the top hashmap entries
    counts <- H.toList freqtable
    traverse prettyPrint $ cutoff $ sortOn (Down . snd) counts
    pure ()


prettyPrint (a,b) = putStrLn $ a <> " " <> show b

incf Nothing  = Just 1
incf (Just x) = Just (x + 1)
{-# INLINE incf #-}
