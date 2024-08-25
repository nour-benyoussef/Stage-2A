const express = require('express');
const body_parser = require('body-parser');
const CaissierRouter = require('./routers/caissier.router');
const ArticleRouter = require('./routers/article.router');
const VenteRouter = require('./routers/vente.router');
const AdminRouter = require ('./routers/admin.router');
const app = express();

app.use(body_parser.json());
app.use('/',CaissierRouter);
app.use('/',ArticleRouter);
app.use('/',VenteRouter);
app.use('/',AdminRouter);

module.exports = app;