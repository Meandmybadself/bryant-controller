if (!process.env.BRYANT_USER) {
  require('dotenv').config()
}

const BryantController = require('./lib/bryant-controller/index.js')
new BryantController(process.env.BRYANT_USER, process.env.BRYANT_PASSWORD)
