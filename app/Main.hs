module Main where

import System.Environment (lookupEnv)
import Network.Wai.Handler.Warp
import Data.Maybe
import Javascript
  
main :: IO ()
main = do
  pStr <- fromMaybe "8080" <$> lookupEnv "PORT"
  let port = read pStr :: Int
  run port app