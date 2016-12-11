if (!process.env.BRYANT_USER) {
  require('dotenv').config()
}

let BryantController = require('./lib/bryant-controller/index.js')
let b = new BryantController()

 Promise.all([b.login(process.env.BRYANT_USER, process.env.BRYANT_PASSWORD), b.getLocations()])
 .then((data) => {
   console.log('data', data)
 })
 .catch((e) => {
   console.log('error', e)
 })

// WZ4ZHY8bSu6l%2BClND0v0HGpFLig%3D

console.log(b._generateSignature('https://www.app-api.eng.bryant.com/users/jeffandashley/locations', oauthObj, 'GET'))
