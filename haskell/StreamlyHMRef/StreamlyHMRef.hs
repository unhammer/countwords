-- Based on
-- https://github.com/composewell/streamly-examples/blob/master/examples/WordFrequency.hs
-- but I don't seem to have classifyMutWith so explicitly making a HashMap of IORefs

import Data.Char (isSpace)
import Data.Foldable (traverse_)
import Data.Function ((&))
import System.Environment (getArgs)
import System.IO          (stdin)
import Data.IORef (newIORef, readIORef, modifyIORef')

import qualified Data.Char as Char
import Data.FastChar
import qualified Data.HashMap.Strict as Map
import qualified Data.List as List
import qualified Data.Ord as Ord
import qualified Streamly.Data.Fold as Fold
import qualified Streamly.Internal.FileSystem.File as File (toBytes)
import qualified Streamly.Internal.FileSystem.Handle as Handle
import qualified Streamly.Prelude as Stream
import qualified Streamly.Unicode.Stream as Unicode

main :: IO ()
main = do
    args <- getArgs
    let cutoff | length args > 0 = take (read $ head args) -- no error handling, to simplify the example
               | otherwise       = id

    mp <-
        let
            alter Nothing    = Just <$> newIORef (1 :: Int)
            alter (Just ref) = modifyIORef' ref (+ 1) >> return (Just ref)
        in Stream.unfold Handle.read stdin
         & Unicode.decodeUtf8                   -- SerialT IO Char
         & Stream.map toLower                   -- SerialT IO Char
         & Stream.wordsBy isSpace Fold.toList   -- SerialT IO String
         & Stream.filter (all isAlpha)          -- SerialT IO String
         & Stream.foldlM' (flip (Map.alterF alter)) (return Map.empty) -- IO (Map String (IORef Int))

    -- Print the top hashmap entries
    counts <-
        let readRef (w, ref) = do
                cnt <- readIORef ref
                return (w, cnt)
         in Map.toList mp
          & mapM readRef

    traverse_ prettyPrint $ cutoff $ List.sortOn (Ord.Down . snd) counts


prettyPrint (a,b) = putStrLn $ a <> " " <> show b
