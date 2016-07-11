if (!process.env.BRYANT_USER) {
  require('dotenv').config()
}

let BryantController = require('./lib/bryant-controller/index.js');
let b = new BryantController(process.env.BRYANT_USER, process.env.BRYANT_PASSWORD);
