app = do require("express")
configure = () ->

    # Configure Express
    @enable "strict routing"
    @use do require("express-slash")
    @use do require("compression")
    @set("views", "browser/partials")
    @set("view engine", "jade")

    # Force SSL Redirection in Production
    if process.env.NODE_ENV == "production"
        @use "*", (req, res, next) ->
            if req.headers["x-forwarded-proto"] != "https"
                res.redirect 301, "https://" + req.hostname + req.originalUrl
            else next()

    # Define Static Paths
    bower  = "#{__dirname}/../bower_components/"
    client = "#{__dirname}/../browser/"

    # Setup Application Asset Pipeline
    @get "/", (req, res) -> res.render("index")
    browserify = require("browserify-middleware")
    @use "/tinycranes.js", browserify "#{client}/tinycranes.coffee",
        extensions: [".coffee"]
        transform: require("coffeeify")
    @use           require("harp")    .mount client
    @use "/bower", require("express") .static bower

    # Application Routing Table
    require("./entry")(@)
    require("./portfolio")(@)
    require("./rss")(@)
    return @

# Start the Express Server
configure.call(app).listen(process.env.PORT or 8080)
