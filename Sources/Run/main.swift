import App

// config
let config = try Config()
try config.setup()

// droplet
let drop = try Droplet(config)
try drop.setup()

// run
try drop.run()
