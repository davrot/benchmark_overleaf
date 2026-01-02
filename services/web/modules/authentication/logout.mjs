let OIDCAuthenticationController 
if (process.env.EXTERNAL_AUTH.includes('oidc')) {
  OIDCAuthenticationController = await import('./oidc/app/src/OIDCAuthenticationController.mjs')
}
export default async function logout(req, res, next) {
  switch(req.user.externalAuth) {
    case 'oidc':
      return OIDCAuthenticationController.default.passportLogout(req, res, next)
    default: 
      next()
  }
}
