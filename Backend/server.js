const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json({extended: true}));
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.json());

const authRouter = require("./routes/authRoutes");
app.use("/auth", authRouter);

const individualRouter = require("./routes/individualRoutes");
app.use("/individual", individualRouter);

const ticketRouter = require("./routes/ticketRoutes");
app.use("/ticket", ticketRouter);

const ticketingRouter = require("./routes/ticketingRoutes");
app.use("/ticketing", ticketingRouter);

const marketRouter = require("./routes/marketRoutes");
app.use("/market", marketRouter);

const kasRouter = require("./routes/kasRoutes");
app.use("/kas", kasRouter);

const screenRouter = require("./routes/screenRoutes");
app.use("/screen", screenRouter);

let port = process.env.PORT || 3000;
app.listen(port, function () {
    return console.log("Started user authentication server listening on port " + port);
});