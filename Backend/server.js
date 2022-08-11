const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json({extended: true}));
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.json());

const authRouter = require("./routes/routes");
app.use("/", authRouter);

const kasRouter = require("./routes/kasRoutes");
app.use("/kas", kasRouter);

let port = process.env.PORT || 3000;
app.listen(port, function () {
    return console.log("Started user authentication server listening on port " + port);
});
