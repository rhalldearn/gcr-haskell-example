{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module Main where

import Data.Proxy
import Control.Concurrent (forkIO)
import Control.Monad (forever)
import Control.Monad.Trans (liftIO)
import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics (Generic)
import Network.Wai.Handler.Warp (run)
import System.Environment (getArgs)
import Servant
import Servant.Auth.Server
import Servant.Auth.Server.SetCookieOrphan ()

import System.Environment (lookupEnv)
import Network.Wai.Handler.Warp
import Data.Maybe
-- import Javascript
import ServerAuth
  
-- main :: IO ()
-- main = do
--   pStr <- fromMaybe "8080" <$> lookupEnv "PORT"
--   let port = read pStr :: Int
--   run port app

main :: IO ()
main = do
  pStr <- fromMaybe "8080" <$> lookupEnv "PORT"
  let port = read pStr :: Int
  args <- getArgs
  let usage = "Usage: readme (JWT|Cookie)"
  case args of
    ["JWT"] -> mainWithJWT port
    ["Cookie"] -> mainWithCookies port
    e -> putStrLn $ "Arguments: \"" ++ unwords e ++ "\" not understood\n" ++ usage

-- In main, we fork the server, and allow new tokens to be created in the
-- command line for the specified user name and email.
mainWithJWT :: Int -> IO () 
mainWithJWT port = do
  -- We generate the key for signing tokens. This would generally be persisted,
  -- and kept safely
  myKey <- generateKey
  -- Adding some configurations. All authentications require CookieSettings to
  -- be in the context.
  let jwtCfg = defaultJWTSettings myKey
      cfg = defaultCookieSettings :. jwtCfg :. EmptyContext
      --- Here we actually make concrete
      api = Proxy :: Proxy (API '[JWT])
  _ <- forkIO $ run port $ serveWithContext api cfg (server defaultCookieSettings jwtCfg)

  putStrLn "Started server on localhost:7249"
  putStrLn "Enter name and email separated by a space for a new token"

  forever $ do
     xs <- words <$> getLine
     case xs of
       [name', email'] -> do
         etoken <- makeJWT (User name' email') jwtCfg Nothing
         case etoken of
           Left e -> putStrLn $ "Error generating token:t" ++ show e
           Right v -> putStrLn $ "New token:\t" ++ show v
       _ -> putStrLn "Expecting a name and email separated by spaces"

mainWithCookies :: Int -> IO ()
mainWithCookies port = do
  -- We *also* need a key to sign the cookies
  myKey <- generateKey
  -- Adding some configurations. 'Cookie' requires, in addition to
  -- CookieSettings, JWTSettings (for signing), so everything is just as before
  let jwtCfg = defaultJWTSettings myKey
      cfg = defaultCookieSettings :. jwtCfg :. EmptyContext
      --- Here is the actual change
      api = Proxy :: Proxy (API '[Cookie])
  run port $ serveWithContext api cfg (server defaultCookieSettings jwtCfg)



