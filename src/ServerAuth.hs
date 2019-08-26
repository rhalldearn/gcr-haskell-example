{-# OPTIONS_GHC -fno-warn-unused-binds #-}
{-# OPTIONS_GHC -fno-warn-deprecations #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}

module ServerAuth where

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

data Auth (auths :: [*]) val

data AuthResult val
  = BadPassword
  | NoSuchUser
  | Authenticated val
  | Indefinite

data User = User { name :: String, email :: String }
   deriving (Eq, Show, Read, Generic)

instance ToJSON User
instance ToJWT User
instance FromJSON User
instance FromJWT User

data Login = Login { username :: String, password :: String }
   deriving (Eq, Show, Read, Generic)

instance ToJSON Login
instance FromJSON Login

type Protected
   = "name" :> Get '[JSON] String
 :<|> "email" :> Get '[JSON] String


-- | 'Protected' will be protected by 'auths', which we still have to specify.
protected :: Servant.Auth.Server.AuthResult User -> Server Protected
-- If we get an "Authenticated v", we can trust the information in v, since
-- it was signed by a key we trust.
protected (Servant.Auth.Server.Authenticated user) = return (name user) :<|> return (email user)
-- Otherwise, we return a 401.
protected _ = throwAll err401

type Unprotected =
 "login"
     :> ReqBody '[JSON] Login
     :> PostNoContent '[JSON] (Headers '[ Header "Set-Cookie" SetCookie
                                        , Header "Set-Cookie" SetCookie]
                                       NoContent)
  :<|> Raw

unprotected :: CookieSettings -> JWTSettings -> Server Unprotected
unprotected cs jwts = checkCreds cs jwts :<|> serveDirectory "static"

type API auths = (Servant.Auth.Server.Auth auths User :> Protected) :<|> Unprotected

server :: CookieSettings -> JWTSettings -> Server (API auths)
server cs jwts = protected :<|> unprotected cs jwts

checkCreds :: CookieSettings
           -> JWTSettings
           -> Login
           -> Handler (Headers '[ Header "Set-Cookie" SetCookie
                                , Header "Set-Cookie" SetCookie]
                               NoContent)
checkCreds cookieSettings jwtSettings (Login "Ali Baba" "Open Sesame") = do
   -- Usually you would ask a database for the user info. This is just a
   -- regular servant handler, so you can follow your normal database access
   -- patterns (including using 'enter').
   let usr = User "Ali Baba" "ali@email.com"
   mApplyCookies <- liftIO $ acceptLogin cookieSettings jwtSettings usr
   case mApplyCookies of
     Nothing           -> throwError err401
     Just applyCookies -> return $ applyCookies NoContent
checkCreds _ _ _ = throwError err401